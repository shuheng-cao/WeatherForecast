from rest_framework import serializers

from weather.models import BlogPost

class BlogPostSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlogPost
        fields = ('pk', 'title', 'description')
        read_only_fields = ['pk','title']