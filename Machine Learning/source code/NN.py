import numpy as np
import random
import json
import CNN
import loader

        
def preprocess_data(size):
    training_size = int(size * 0.9)
    all_data = loader.load_data(size)
    random.shuffle(all_data)
    training_data = all_data[:training_size]
    validation_data = all_data[training_size:]

    training_in     = [x[2] for x in training_data]
    training_out    = [x[-1] for x in training_data]
    validation_in   = [x[2] for x in validation_data]
    validation_out  = [x[-1] for x in validation_data]

    for i in range(training_size):
        training_in[i][0] = training_in[i][0]
        training_in[i][3] = training_in[i][3] / 100
        training_in[i][5] = training_in[i][5] / 1000
        training_in[i][9] = training_in[i][9] / 10
        
        training_out[i] = np.append(vectorize(int(training_out[i][0]), 5), [[training_out[i][1]/100]], axis=0)

    for i in range(size - training_size):
        validation_in[i][0] = min(1, validation_in[i][0])
        validation_out[i] = np.append(vectorize(int(validation_out[i][0]), 5), [[validation_out[i][1]/100]], axis=0)
        validation_in[i][3] = validation_in[i][3] / 100
        validation_in[i][5] = validation_in[i][5] / 1000
        validation_in[i][9] = validation_in[i][9] / 10
        

    return [(x, y) for (x, y) in zip(np.array(training_in).reshape(training_size,10,1), np.array(training_out))], \
        [(x, y) for (x, y) in zip(np.array(validation_in).reshape(size-training_size,10,1), np.array(validation_out))]


def nn_training(cached = True):
    
    if cached:
        model = NeuralNetwork([0])
        model.load("cache/nn_model2")
    else:
        model = NeuralNetwork([10, 32, 32, 6])
    
    train_data, test_data = preprocess_data(5000)
    model.gradientDescent(train_data,test_data, 0.75, 0.0, 10, 100)

    train_data, test_data = preprocess_data(7500)
    model.gradientDescent(train_data,test_data, 0.5, 0.1, 10, 100)

    train_data, test_data = preprocess_data(10000)
    model.gradientDescent(train_data,test_data, 0.1, 0.2, 10, 200)

    model.save("cache/nn_model2")

def nn_predicting(data):
    model = NeuralNetwork([0])
    model.load("cache/nn_model2")
    res = model.forwardPropagation(data)

    return res

# MARK: everything below build a neural network from scratch
def sigmoid(x):
    return 1.0/(1.0+np.exp(-x))

def sigmoid_delta(x):
    """
    derivative of sigmoid
    """
    return sigmoid(x) * (1-sigmoid(x))

def vectorize(i, n):
    """
    convert integer i into array of size n where only ith entry is 1
    """
    vec = np.zeros((n, 1))
    vec[i] = 1.0
    return vec

class CostFunction():
    def cost(self, a, y):
        """
        Return the cost associated with an output ``a`` and desired output``y``.
        """
        return 0.5*np.linalg.norm(a-y)**2

    def delta(self, z, a, y):
        """Return the error delta from the output layer."""
        return (a-y) * sigmoid_delta(z)

class NeuralNetwork():
    def __init__(self, layers):
        """
        layers is a list where each element in the list representing the number of neurons in that layer
        """
        self.layers     =   layers
        # the output layer don't have weights and biases, so we used [1:]
        # also, assume current layer has n neurons and next layer has m, we want our weight matrix to be m by n
        self.biases     =   [np.random.randn(n, 1) for n in layers[1:]]
        self.weights    =   [np.random.randn(m, n) / np.sqrt(n) for n, m in zip(layers[:-1], layers[1:])]

    def forwardPropagation(self, a):
        for weight, bias in zip(self.weights, self.biases):
            # weight is m by n and a is n by 1
            z = np.dot(weight, a) + bias
            a = sigmoid(z)
        return a

    def backwardPropagation(self, x, y):
        delta_biases    =   [np.zeros(bias.shape) for bias in self.biases]
        delta_weights   =   [np.zeros(weight.shape) for weight in self.weights]
        # current activation
        a = x
        a_vectors = [a]
        z_vectors = []

        # forward propagation
        for weight, bias in zip(self.weights, self.biases):
            z = np.dot(weight, a) + bias
            z_vectors.append(z)
            a = sigmoid(z)
            a_vectors.append(a)
        
        # backward propagation
        # 1. Output layer
        delta = CostFunction().delta(z_vectors[-1], a_vectors[-1], y)                                  # (BP1)
        delta_biases[-1]    = delta                                                     # (BP3)
        delta_weights[-1]   = np.dot(delta, a_vectors[-2].transpose())                  # (BP4)

        # 2. Other layers, using reverse order
        for l in range(2, len(self.layers)):
            z = z_vectors[-l]
            delta = np.dot(self.weights[-l+1].transpose(), delta) * sigmoid_delta(z)    # (BP2)
            delta_biases[-l]    = delta                                                 # (BP3)
            delta_weights[-l]   = np.dot(delta, a_vectors[-l-1].transpose())            # (BP4)

        return delta_biases, delta_weights

    def batchUpdate(self, batch_data, learning_rate, regularization_rate, total_number):
        delta_biases    =   [np.zeros(bias.shape) for bias in self.biases]
        delta_weights   =   [np.zeros(weight.shape) for weight in self.weights]
        # sum over all 
        for x, y in batch_data:
            D_delta_biases, D_delta_weights = self.backwardPropagation(x, y)
            delta_biases    =    [db+ddb for db, ddb in zip(delta_biases, D_delta_biases)]
            delta_weights   =    [dw+ddw for dw, ddw in zip(delta_weights, D_delta_weights)]

        self.weights = [(1-learning_rate*(regularization_rate/total_number))*w-(learning_rate/len(batch_data))*nw for w, nw in zip(self.weights, delta_weights)]
        self.biases = [b-(learning_rate/len(batch_data))*nb for b, nb in zip(self.biases, delta_biases)]

    def total_cost(self, data_set, regularization_rate):
        """
        As usual, data_set should be a pair of vector (x, y), where x is input and y is vectorized output
        """
        cost = 0.0
        for x, y in data_set:
            o = self.forwardPropagation(x)
            cost +=  CostFunction().cost(o, y) / len(data_set)
        cost += 0.5 * regularization_rate * sum(np.linalg.norm(w)**2 for w in self.weights)  / len(data_set)
        return cost

    def accuracy(self, data_set):
        """
        Return the number of inputs that produce the desired output
        """        
        accuracy = 0
        for (x, y) in data_set:
            output = self.forwardPropagation(x)
            if np.argmax(output[:5]) == np.argmax(y[:5]) and abs(output[5] - y[5]) < 0.1:
                accuracy += 1
        return accuracy


    def gradientDescent(self, training_set, test_set, learning_rate, regularization_rate, batch_size, epochs):
        """
        training_set and test_set are two list of pair data (x, y), where x is input vector and y is answer vector.
        This function will return all the costs and accuracies for plotting or any other judging use
        """

        print("Initial cost and accuracy")


        cost = self.total_cost(training_set, regularization_rate)
        print("Cost on training data: {}".format(cost))

        accuracy = self.accuracy(training_set)
        print("Accuracy on training data: {:.0%}".format(float(accuracy)/float(len(training_set))))

        cost = self.total_cost(test_set, regularization_rate)
        print("Cost on evaluation data: {}".format(cost))

        accuracy = self.accuracy(test_set)
        print("Accuracy on evaluation data: {:.0%}".format(float(accuracy) / float(len(test_set))))
        print

        training_accuracy, training_cost, test_accuracy, test_cost = [], [], [], []
        for i in range(epochs):
            random.shuffle(training_set)
            # for j in range(0, len(training_set), batch_size):
            mini_batches = [training_set[k:k+batch_size] for k in range(0, len(training_set), batch_size)]
            for mini_batch in mini_batches:
                self.batchUpdate(mini_batch, learning_rate, regularization_rate, len(training_set))

            if (i+1) % 10 == 0:
                print("Epoch {} training complete".format(i+1))

                cost = self.total_cost(training_set, regularization_rate)
                training_cost.append(cost)
                print("Cost on training data: {}".format(cost))

                accuracy = self.accuracy(training_set)
                training_accuracy.append(accuracy)
                print("Accuracy on training data: {:.0%}".format(float(accuracy)/float(len(training_set))))

                cost = self.total_cost(test_set, regularization_rate)
                test_cost.append(cost)
                print("Cost on evaluation data: {}".format(cost))

                accuracy = self.accuracy(test_set)
                test_accuracy.append(accuracy)
                print("Accuracy on evaluation data: {:.0%}".format(float(accuracy) / float(len(test_set))))
                print
        
        return training_accuracy, training_cost, test_accuracy, test_cost

    def save(self, name):
        """
        save current neural network data to file `name`
        """
        data = {"layers": self.layers,
                "weights": [w.tolist() for w in self.weights],
                "biases": [b.tolist() for b in self.biases]}
        f = open(name, "w")
        json.dump(data, f)
        f.close()
        print("Saved model to disk")

    def load(self, name):
        """
        overwrite current network with file `name`
        """
        f = open(name, "r")
        data = json.load(f)
        f.close()
        self.layers = data["layers"]
        self.weights = [np.array(weight) for weight in data["weights"]]
        self.biases = [np.array(bias) for bias in data["biases"]]
        print("Loaded model from disk")





            



