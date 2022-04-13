from base64 import b64encode, b64decode
from io import BytesIO

from PIL import Image
from django.core.files import File


def create_thumbnail(image_field):
    image = Image.open(image_field)
    image.thumbnail(size=(256, 256))
    image_file = BytesIO()
    image.save(image_file, image.format)
    return File(image_file, f'{image_field.name}.thumbnail')


def store_file(image_field):
    return b64encode(image_field.read()).decode('utf-8'), image_field.name.split('/')[-1]


def restore_file(data, name):
    decoded = b64decode(data.encode('utf-8'))
    return File(BytesIO(decoded), name)
