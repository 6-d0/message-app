from rest_framework.generics import CreateAPIView, ListAPIView
from messages.api.models import Test
from messages.api.serializers import TestSerializer
class TestViews(CreateAPIView, ListAPIView):
    queryset = Test.objects.all()
    serializer_class = TestSerializer

    def post(self, request, *args, **kwargs):
        serializer = TestSerializer(data=request.data)
        if serializer.is_valid():
            return self.create(request, *args, **kwargs)
        else:
            return self.serializer_class.errors, 400
        return super().post(request, *args, **kwargs)

    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
