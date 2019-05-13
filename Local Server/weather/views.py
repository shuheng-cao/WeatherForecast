import sys
sys.path.append("/Users/caoshuheng 1/Desktop/Weather?/Machine Learning/source code/")
from NN import nn_predicting, nn_training
from CNN import cnn_training

from django.shortcuts import render
from datetime import datetime
from django.http import JsonResponse


def refresh(request):
	res = nn_predicting()
	context = {
		'city': request.get_full_path().split("/")[-1],
		'time': f"{str(datetime.now())}",
		'request': "refresh",
		'log': "TODO",
		'result': f"{res}"
	}
	return JsonResponse(context)

def retrain(request):
	cnn_training()
	nn_training()
	context = {
		'city': request.get_full_path().split("/")[-1],
		'time': f"{str(datetime.now())}",
		'request': "retrain"
	}
	return JsonResponse(context)

def home(request):
	return render(request, "weather/index.html", {})