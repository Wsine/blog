# Python实现nb(朴素贝叶斯)

## 运行环境
- Pyhton3
- numpy科学计算模块

## 计算过程

```flow
st=>start: 开始
op1=>operation: 读入数据
op2=>operation: 格式化数据
op3=>operation: 计算测试文本对预测情感的相关度
op4=>operation: 计算推断出情感的概率
e=>end

st->op1->op2->op3->op4->e
```

## 输入样例

```
/* Dataset.txt */
文本编号	词列表（以空格分隔）	公众"感动"的概率
训练文本1	消防员 冲进 火场 救出 男童	1
训练文本2	消防员 多次 冲进 火场 救人 不幸 身亡	0.5
训练文本3	6旬 老人 跳楼 自杀 身亡	0.1
训练文本4	疑犯 枪杀 出租车 司机	0
训练文本5	医师 误 把 肾脏 当 肝脏 致人 身亡	0
测试文本1	癌症 老人 成功 手术	?
测试文本2	男子 枪杀 老人 后 自杀	?
测试文本3	消防员 冲进 火场 将 男童 救出	?
测试文本4	出租车 司机 免费 搭载 老人	?
测试文本5	医师 误 把 患者 肝脏 捅破 致人 身亡	?
```

## 代码实现

```python
# -*- coding: utf-8 -*-
__author__ = 'Wsine'

from numpy import *
import operator
import time

SIZE_OF_DATA = 5
SIZE_OF_TEST = 5

def read_input(filename):
	with open(filename) as fr:
		corpus = []
		for text in fr.readlines()[1:]:
			for word in text.strip().split('\t')[1].split():
				corpus.append(word)
		allwords = set(corpus)

	matN = len(allwords)
	returnMat = zeros((SIZE_OF_DATA + SIZE_OF_TEST, matN))
	shares = []
	index = 0
	with open(filename) as fr:
		for line in fr.readlines()[1:]:
			setFromLine = set(line.strip().split('\t')[1].split())
			oneLine = []
			for s in allwords:
				if s in setFromLine:
					oneLine.append(1)
				else:
					oneLine.append(0)
			returnMat[index, :] = oneLine
			if index < SIZE_OF_DATA:
				shares.append(float(line.strip().split('\t')[-1].strip()))
			index += 1
	return returnMat[:SIZE_OF_DATA,:], returnMat[SIZE_OF_DATA:,:], shares

def norm(inputMat):
	outputMat = inputMat.copy()
	m, n = shape(inputMat)
	for i in range(m):
		lineSum = sum(inputMat[i, :])
		for j in range(n):
			outputMat[i, j] = inputMat[i, j] / lineSum
	return outputMat

def cosineFunction(a, b):
	l = len(a)
	up = 0
	for i in range(l):
		up += a[i] * b[i]
	down1 = linalg.norm(a)
	down2 = linalg.norm(b)
	return (up / (down1 * down2))

def classify(trainDataSet, testDataSet, dataShares):
	trainDataSet = trainDataSet.transpose()
	emotionMat = dot(trainDataSet, dataShares) # 第i个词和情感的相关度
	count = sum(trainDataSet)
	for i, word in enumerate(emotionMat):
		emotionMat[i] = word * sum(trainDataSet[i]) / count
		# 由词推断出情感的概率 = 
		#					当前文本已知情感出现词的概率 
		#				  * 当前训练文本中的情感概率值 
		#				  / 所有文本中出现词的概率
	predictShares = dot(testDataSet, emotionMat)
	return norm(mat(predictShares))

def main():
	trainMat, testMat, shares = read_input('Dataset.txt')
	normTrainMat = norm(trainMat)
	normTestMat = norm(testMat)
	predictShares = classify(normTrainMat, normTestMat, shares)
	print(predictShares)

if __name__ == '__main__':
	main()
```

## 输出样例

```
[[ 0.01457495  0.02331992  0.87251383  0.01165996  0.07793135]]
```