from django.shortcuts import render

from django.http import JsonResponse

def get_weather(request):
	context = {
		'city': request.get_full_path().split("/")[-1],
		'time': 'some description as well',
		'request': request.get_full_path()
	}
	return JsonResponse(context)


def home(request):
	return render(request, "weather/index.html", {})