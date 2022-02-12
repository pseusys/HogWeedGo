from base64 import b64encode, b64decode
from io import BytesIO

from PIL import Image
from django.core.files import File
from django.core.files.uploadedfile import InMemoryUploadedFile


def create_thumbnail(image_field):
    image = Image.open(image_field)
    image.thumbnail(size=(256, 256))
    image_file = BytesIO()
    image.save(image_file, image.format)
    return InMemoryUploadedFile(
        image_file,
        'thumbnail', f'{image_field.name}.thumbnail',
        image_field.file.content_type,
        image_field.size,
        image_field.file.charset
    )


def store_file(image_field):
    return b64encode(image_field.read()).decode('utf-8'), image_field.name.split('/')[-1]


def restore_file(data, name):
    decoded = b64decode(data.encode('utf-8'))
    return File(BytesIO(decoded), name)
