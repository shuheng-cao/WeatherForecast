import numpy as np
import random
import json

def sigmoid(x):
    return float(1)/(float(1)+np.exp(x))

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
        

class CrossEntropy():
    def cost(self, a, y):
        """
        a is the predicted vector and y is the answer vector
        """
        return np.sum(np.nan_to_num(-y * np.log(a) - (1-y) * np.log(1-a)))

    def delta(self, a, y):
        return a-y

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
        delta = CrossEntropy().delta(a_vectors[-1], y)                                  # (BP1)
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
            cost += ( CrossEntropy().cost(o, y) + 0.5 * (regularization_rate * sum(np.linalg.norm(weight) ** 2 for weight in self.weights)) ) / len(data_set)
        return cost

    def accuracy(self, data_set):
        """
        If f1 is false, return the number of inputs that produce the desired output
        Else, return the F1 score defined by 2 / (1/precision + 1/recall)
        """        
        results  = [(np.argmax(self.forwardPropagation(x)), np.argmax(y)) for (x, y) in data_set]
        accuracy = sum(int(x == y) for (x, y) in results)
        return accuracy


    def gradientDescent(self, training_set, test_set, learning_rate, regularization_rate, batch_size, epochs):
        """
        training_set and test_set are two list of pair data (x, y), where x is input vector and y is answer vector.
        This function will return all the costs and accuracies for plotting or any other judging use
        """
        training_accuracy, training_cost, test_accuracy, test_cost = [], [], [], []
        for i in range(epochs):
            random.shuffle(training_set)
            # for j in range(0, len(training_set), batch_size):
            mini_batches = [training_set[k:k+batch_size] for k in range(0, len(training_set), batch_size)]
            for mini_batch in mini_batches:
                self.batchUpdate(mini_batch, learning_rate, regularization_rate, len(training_set))

            print("Epoch %s training complete" % i)
            training_accuracy.append(self.accuracy(training_set))
            test_accuracy.append(self.accuracy(test_set))
            training_cost.append(self.total_cost(training_set, regularization_rate))
            test_cost.append(self.total_cost(training_set, regularization_rate))

            print("\tCost on training data: {}".format(training_cost[-1]))
            print("\tAccuracy on training data: {}".format(training_accuracy[-1]))
            print("\tCost on test data: {}".format(test_cost[-1]))
            print("\tAccuracy on test data: {}".format(test_accuracy[-1]))
        
        return training_accuracy, training_cost, test_accuracy, test_cost

    def save(self, name):
        """
        save current neural network data to file `name`
        """
        data = {"layers": self.layers,
                "weights": [w.tolist() for w in self.weights],
                "biases": [b.tolist() for b in self.biases]
                }
        f = open(name, "w")
        json.dump(data, f)
        f.close()

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
        

    




            



