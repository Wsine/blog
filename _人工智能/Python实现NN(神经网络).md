#Python实现NN(神经网络)

> 参考自Github开源代码：https://github.com/dennybritz/nn-from-scratch

##运行环境
- Pyhton3
- numpy(科学计算包)
- matplotlib(画图所需，不画图可不必)
- sklearn(人工智能包，生成数据使用)

##计算过程

```flow
st=>start: 开始
e=>end: 结束
op1=>operation: 读入数据
op2=>operation: 格式化数据
cond=>condition: 是否达到迭代次数
op3=>operation: 正向传播获取参数
op4=>operation: 后向传播计算参数
op5=>operation: 梯度下降更新参数
op6=>operation: 输出结果

st->op1->op2->cond
cond(yes)->op6->e
cond(no)->op3->op4->op5
```

##输入样例

none

##代码实现

```python
# -*- coding: utf-8 -*-
__author__ = 'Wsine'

import numpy as np
import sklearn
import sklearn.datasets
import sklearn.linear_model
import matplotlib.pyplot as plt
import matplotlib
import operator
import time

def createData(dim=200, cnoise=0.20):
	"""
	输出：数据集, 对应的类别标签
	描述：生成一个数据集和对应的类别标签
	"""
	np.random.seed(0)
	X, y = sklearn.datasets.make_moons(dim, noise=cnoise)
	plt.scatter(X[:, 0], X[:, 1], s=40, c=y, cmap=plt.cm.Spectral)
	#plt.show()
	return X, y

def plot_decision_boundary(pred_func, X, y):
	"""
	输入：边界函数, 数据集, 类别标签
	描述：绘制决策边界(画图用)
	"""
	# 设置最小最大值, 加上一点外边界
	x_min, x_max = X[:, 0].min() - .5, X[:, 0].max() + .5
	y_min, y_max = X[:, 1].min() - .5, X[:, 1].max() + .5
	h = 0.01
	# 根据最小最大值和一个网格距离生成整个网格
	xx, yy = np.meshgrid(np.arange(x_min, x_max, h), np.arange(y_min, y_max, h))
	# 对整个网格预测边界值
	Z = pred_func(np.c_[xx.ravel(), yy.ravel()])
	Z = Z.reshape(xx.shape)
	# 绘制边界和数据集的点
	plt.contourf(xx, yy, Z, cmap=plt.cm.Spectral)
	plt.scatter(X[:, 0], X[:, 1], c=y, cmap=plt.cm.Spectral)

def calculate_loss(model, X, y):
	"""
	输入：训练模型, 数据集, 类别标签
	输出：误判的概率
	描述：计算整个模型的性能
	"""
	W1, b1, W2, b2 = model['W1'], model['b1'], model['W2'], model['b2']
	# 正向传播来计算预测的分类值
	z1 = X.dot(W1) + b1
	a1 = np.tanh(z1)
	z2 = a1.dot(W2) + b2
	exp_scores = np.exp(z2)
	probs = exp_scores / np.sum(exp_scores, axis=1, keepdims=True)
	# 计算误判概率
	corect_logprobs = -np.log(probs[range(num_examples), y])
	data_loss = np.sum(corect_logprobs)
	# 加入正则项修正错误(可选)
	data_loss += reg_lambda/2 * (np.sum(np.square(W1)) + np.sum(np.square(W2)))
	return 1./num_examples * data_loss

def predict(model, x):
	"""
	输入：训练模型, 预测向量
	输出：判决类别
	描述：预测类别属于(0 or 1)
	"""
	W1, b1, W2, b2 = model['W1'], model['b1'], model['W2'], model['b2']
	# 正向传播计算
	z1 = x.dot(W1) + b1
	a1 = np.tanh(z1)
	z2 = a1.dot(W2) + b2
	exp_scores = np.exp(z2)
	probs = exp_scores / np.sum(exp_scores, axis=1, keepdims=True)
	return np.argmax(probs, axis=1)

def initParameter(X):
	"""
	输入：数据集
	描述：初始化神经网络算法的参数
		  必须初始化为全局函数！
		  这里需要手动设置！
	"""
	global num_examples
	num_examples = len(X) # 训练集的大小
	global nn_input_dim
	nn_input_dim = 2 # 输入层维数
	global nn_output_dim
	nn_output_dim = 2 # 输出层维数

	# 梯度下降参数
	global epsilon
	epsilon = 0.01 # 梯度下降学习步长
	global reg_lambda
	reg_lambda = 0.01 # 修正的指数

def build_model(X, y, nn_hdim, num_passes=20000, print_loss=False):
	"""
	输入：数据集, 类别标签, 隐藏层层数, 迭代次数, 是否输出误判率
	输出：神经网络模型
	描述：生成一个指定层数的神经网络模型
	"""
	# 根据维度随机初始化参数
	np.random.seed(0)
	W1 = np.random.randn(nn_input_dim, nn_hdim) / np.sqrt(nn_input_dim)
	b1 = np.zeros((1, nn_hdim))
	W2 = np.random.randn(nn_hdim, nn_output_dim) / np.sqrt(nn_hdim)
	b2 = np.zeros((1, nn_output_dim))

	model = {}

	# 梯度下降
	for i in range(0, num_passes):
		# 正向传播
		z1 = X.dot(W1) + b1
		a1 = np.tanh(z1) # 激活函数使用tanh = (exp(x) - exp(-x)) / (exp(x) + exp(-x))
		z2 = a1.dot(W2) + b2
		exp_scores = np.exp(z2) # 原始归一化
		probs = exp_scores / np.sum(exp_scores, axis=1, keepdims=True)
		# 后向传播
		delta3 = probs
		delta3[range(num_examples), y] -= 1
		dW2 = (a1.T).dot(delta3)
		db2 = np.sum(delta3, axis=0, keepdims=True)
		delta2 = delta3.dot(W2.T) * (1 - np.power(a1, 2))
		dW1 = np.dot(X.T, delta2)
		db1 = np.sum(delta2, axis=0)
		# 加入修正项
		dW2 += reg_lambda * W2
		dW1 += reg_lambda * W1
		# 更新梯度下降参数
		W1 += -epsilon * dW1
		b1 += -epsilon * db1
		W2 += -epsilon * dW2
		b2 += -epsilon * db2
		# 更新模型
		model = { 'W1': W1, 'b1': b1, 'W2': W2, 'b2': b2}
		# 一定迭代次数后输出当前误判率
		if print_loss and i % 1000 == 0:
			print("Loss after iteration %i: %f" % (i, calculate_loss(model, X, y)))
	plot_decision_boundary(lambda x: predict(model, x), X, y)
	plt.title("Decision Boundary for hidden layer size %d" % nn_hdim)
	#plt.show()
	return model

def main():
	dataSet, labels = createData(200, 0.20)
	initParameter(dataSet)
	nnModel = build_model(dataSet, labels, 3, print_loss=False)
	print("Loss is %f" % calculate_loss(nnModel, dataSet, labels))

if __name__ == '__main__':
	start = time.clock()
	main()
	end = time.clock()
	print('finish all in %s' % str(end - start))
	plt.show()
```

##输出样例

```
Loss is 0.071316
finish all in 7.221354361552228
```
![](http://images2015.cnblogs.com/blog/701997/201602/701997-20160203185913975-586997559.jpg)