from flask import Flask, jsonify, request, send_from_directory
from flask_pymongo import PyMongo
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from datetime import datetime, timedelta
import os
from bson.objectid import ObjectId
from dotenv import load_dotenv
import json
import base64

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.config["MONGO_URI"] = os.getenv("MONGO_URI", "mongodb+srv://mini_books:mini_books@users.mat5xne.mongodb.net/mini_books")
app.secret_key = os.getenv("SECRET_KEY", "your-secret-key")

# Initialize extensions
mongo = PyMongo(app)
bcrypt = Bcrypt(app)
CORS(app)

# Setup upload directory
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Helper function for responses
def make_response(data, status_code=200):
    """Format JSON response and handle ObjectId serialization"""
    class JSONEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, ObjectId):
                return str(obj)
            if isinstance(obj, datetime):
                return obj.isoformat()
            return json.JSONEncoder.default(self, obj)
    
    response = app.response_class(
        response=JSONEncoder().encode(data),
        status=status_code,
        mimetype='application/json'
    )
    return response

# User management functions
def get_user_by_email(email):
    return mongo.db.users.find_one({"email": email})

def get_user_by_id(user_id):
    return mongo.db.users.find_one({"_id": ObjectId(user_id)})

def create_user(user_data):
    user_data['created_at'] = datetime.now()
    user_data['updated_at'] = datetime.now()
    user_data['is_premium'] = False
    user_data['premium_until'] = None
    
    result = mongo.db.users.insert_one(user_data)
    return result.inserted_id

def update_user_profile(user_id, update_data):
    update_data['updated_at'] = datetime.now()
    result = mongo.db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": update_data}
    )
    return result.modified_count > 0

def update_subscription_status(user_id, is_premium, premium_until=None):
    update_data = {
        'is_premium': is_premium,
        'premium_until': premium_until,
        'updated_at': datetime.now()
    }
    
    result = mongo.db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": update_data}
    )
    return result.modified_count > 0

# Routes
@app.route('/')
def index():
    return jsonify({'message': 'Mini-Books API'})

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@app.route('/api/users/register', methods=['POST', 'GET'])
def register():
    if request.method == 'GET':
        return jsonify({'message': 'This endpoint requires a POST request with JSON data. Use a proper API client.'}), 200
    
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['name', 'email', 'password']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    # Check if user already exists
    existing_user = get_user_by_email(data['email'])
    if existing_user:
        return jsonify({'error': 'Email already registered'}), 409
    
    # Hash password
    data['password'] = bcrypt.generate_password_hash(data['password']).decode('utf-8')
    
    # Create user
    user_id = create_user(data)
    
    return jsonify({'message': 'User registered successfully', 'user_id': str(user_id)}), 201

@app.route('/api/users/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data or 'email' not in data or 'password' not in data:
        return jsonify({'error': 'Email and password are required'}), 400
    
    user = get_user_by_email(data['email'])
    if not user or not bcrypt.check_password_hash(user['password'], data['password']):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    # Prepare user data for response (without password)
    user_data = {
        'id': str(user['_id']),
        'name': user.get('name', ''),
        'email': user['email'],
        'contactNo': user.get('contactNo', ''),
        'is_premium': user.get('is_premium', False),
        'premium_until': user.get('premium_until'),
        'profile_image': user.get('profile_image', '')
    }
    
    return jsonify({
    'user': user_data
    }), 200 

@app.route('/api/users/profile', methods=['GET'])
def get_profile():
    # In a real app, you'd use JWT tokens to identify the user
    # Here we'll just use email from query parameters for simplicity
    email = request.args.get('email')
    if not email:
        return jsonify({'error': 'Email is required'}), 400
    
    user = get_user_by_email(email)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Don't return password in response
    user.pop('password', None)
    
    return make_response(user)

@app.route('/api/users/profile', methods=['PUT'])
def update_profile():
    data = request.get_json()
    email = data.get('email')
    
    if not email:
        return jsonify({'error': 'Email is required'}), 400
    
    user = get_user_by_email(email)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Remove fields that shouldn't be updated directly
    protected_fields = ['password', '_id', 'email', 'is_premium', 'premium_until']
    update_data = {k: v for k, v in data.items() if k not in protected_fields}
    
    success = update_user_profile(user['_id'], update_data)
    
    if success:
        return jsonify({'message': 'Profile updated successfully'}), 200
    else:
        return jsonify({'error': 'Failed to update profile'}), 400

@app.route('/api/users/update-password', methods=['PUT'])
def update_password():
    data = request.get_json()
    email = data.get('email')
    
    if not email:
        return jsonify({'error': 'Email is required'}), 400
    
    if 'current_password' not in data or 'new_password' not in data:
        return jsonify({'error': 'Current password and new password are required'}), 400
    
    user = get_user_by_email(email)
    if not user or not bcrypt.check_password_hash(user['password'], data['current_password']):
        return jsonify({'error': 'Current password is incorrect'}), 401
    
    # Hash new password
    hashed_password = bcrypt.generate_password_hash(data['new_password']).decode('utf-8')
    success = update_user_profile(user['_id'], {'password': hashed_password})
    
    if success:
        return jsonify({'message': 'Password updated successfully'}), 200
    else:
        return jsonify({'error': 'Failed to update password'}), 400

@app.route('/api/users/subscription', methods=['POST'])
def update_subscription():
    data = request.get_json()
    email = data.get('email')
    
    if not email:
        return jsonify({'error': 'Email is required'}), 400
    
    if 'is_premium' not in data:
        return jsonify({'error': 'Subscription status is required'}), 400
    
    user = get_user_by_email(email)
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    premium_until = None
    if data['is_premium']:
        # Set premium expiration date (e.g., 1 month)
        premium_until = (datetime.now() + timedelta(days=30)).isoformat()
    
    success = update_subscription_status(user['_id'], data['is_premium'], premium_until)
    
    if success:
        return jsonify({
            'message': 'Subscription updated successfully',
            'is_premium': data['is_premium'],
            'premium_until': premium_until
        }), 200
    else:
        return jsonify({'error': 'Failed to update subscription'}), 400

@app.route('/api/users/upload-profile-image', methods=['POST'])
def upload_profile_image():
    try:
        data = request.json
        email = data.get('email')
        base64_image = data.get('image')
        
        if not email or not base64_image:
            return jsonify({'error': 'Email and image are required'}), 400
            
        # Find the user
        user = mongo.db.users.find_one({'email': email})
        if not user:
            return jsonify({'error': 'User not found'}), 404
            
        # Process the base64 image
        try:
            # Remove data:image/jpeg;base64, prefix if it exists
            if ',' in base64_image:
                base64_image = base64_image.split(',')[1]
                
            image_data = base64.b64decode(base64_image)
            
            # Create a filename based on user ID
            filename = f"profile_{user['_id']}.jpg"
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            
            # Write the decoded image to the file system
            with open(filepath, 'wb') as f:
                f.write(image_data)
            
            # Create the image URL (relative path)
            image_url = f"/uploads/{filename}"
            
            # Update user profile with image URL
            mongo.db.users.update_one(
                {'_id': user['_id']},
                {'$set': {'profile_image': image_url}}
            )
            
            return jsonify({
                'message': 'Profile image uploaded successfully',
                'profile_image': image_url
            }), 200
            
        except Exception as e:
            return jsonify({'error': f'Error processing image: {str(e)}'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Run the app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)