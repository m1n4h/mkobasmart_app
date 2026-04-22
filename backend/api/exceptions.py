from rest_framework.views import exception_handler


def mkobasmart_exception_handler(exc, context):
    response = exception_handler(exc, context)
    if response is None:
        return response

    data = response.data
    message = 'Request failed'
    details = None

    if isinstance(data, dict):
        if 'detail' in data:
            message = str(data.get('detail'))
        elif 'error' in data:
            error = data.get('error')
            if isinstance(error, dict):
                message = str(error.get('message') or 'Request failed')
                details = error.get('details')
            else:
                message = str(error)
        else:
            message = 'Validation failed'
            details = data
    elif isinstance(data, list):
        message = 'Validation failed'
        details = data
    else:
        message = str(data)

    response.data = {
        'success': False,
        'error': {
            'code': f'http_{response.status_code}',
            'message': message,
            'details': details,
        }
    }
    return response
