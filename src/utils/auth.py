import jwt
from functools import wraps
from flask import request, jsonify
from datetime import datetime, timedelta
import os
from models import User

def generate_token(user_id):
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(days=1)
    }
    return jwt.encode(payload, os.getenv('SECRET_KEY'), algorithm='HS256')

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'mesaj': 'Geçersiz token formatı'}), 401

        if not token:
            return jsonify({'mesaj': 'Token bulunamadı'}), 401

        try:
            data = jwt.decode(token, os.getenv('SECRET_KEY'), algorithms=['HS256'])
            current_user = User.query.get(data['user_id'])
            if not current_user:
                return jsonify({'mesaj': 'Geçersiz token'}), 401
        except:
            return jsonify({'mesaj': 'Geçersiz token'}), 401

        return f(current_user, *args, **kwargs)

    return decorated 