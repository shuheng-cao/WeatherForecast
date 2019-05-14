# Weather Forcast

### *Warning: This APP is built on iPhone Xs Max, haven't been adapted for other version. Sorry for any inconvenience.*

* ## Quick Presentation
  
  <a href="https://www.youtube.com/watch?v=IjqtOU0YoJM&t=8s
" target="_blank"><img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/IMG_4732.PNG" 
alt="IMAGE ALT TEXT HERE" width="250" height="540" border="10" /></a>

* ## Breakdowns
  * ## App Introduction
    * ### Page View
      #### Swipe left and right to shift between different views
      #### Swipe up and down for more info and reloading
        <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/page.gif" width="250" height="540" />
    
    * ### Navigation
      #### Using city list to quickly navigate between different cities
      <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/navigation.gif" width="250" height="540" />
      
    * ### Manipulation
      #### Adding and deleting cities as we usually does
      <pre>
       <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/addition.gif" width="250" height="540" />     <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/deletion.gif" width="250" height="540" />
      </pre>
    * ### Developer Mode
      #### A special view controller to have an insight into the *Machine Learning* mechanism.      
      #### By touching refresh button, we will see how the prediction works with detailed logging infomation:
      #### By touching retrain button, we will see how the CNN (Convolutional Neural Network) and NN (Neural Network) are trained:
      <pre>
      <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/predict.gif" width="250" height="540" />      <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/retrain.gif" width="250" height="540" />
      </pre>
      
      #### By toggle the first switch, we will decide whether we use external API or the ML to generate result.
      #### By toggle the second switch, we will decide whether we connect to the local server or not.
      <img src="https://github.com/shuheng-cao/WeatherForecast/blob/master/pics/todo.gif" width="250" height="540" />
  
  * ## Local Server (Django) Setup:
      ```
      pip3 install django
      pip3 install djangorestframework
      python3 manage.py runserver 
      ```
  
  * ## Some data from Machine Learning process:
      * ### TODO: the learning curve and loss curve for CNN and NN
