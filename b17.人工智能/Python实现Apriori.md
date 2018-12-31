# Python实现Apriori

## 运行环境
- Pyhton3

## 计算过程

```flow
st=>start: 开始
e=>end: 结束
op1=>operation: 读入数据
op2=>operation: 递归生成频繁项集
op3=>operation: 关联规则挖掘
op4=>operation: 输出结果

st->op1->op2->op3->op4->e
```

## 输入样例

```
/* Apriori.txt */
文本编号	词列表（以空格分隔）
1	消防员 冲进 火场 救出 男童
2	公务员 患 癌症 保持 在岗
3	消防员 多次 冲进 火场 救人 不幸 身亡
4	老人 成功 进行 免费 白内障 手术
5	海豚 误 吞 排球 后 手术 成功 取出
6	6旬 老人 跳楼 自杀 身亡
7	男子 跳楼 自杀 身亡
8	疑犯 枪杀 出租车 司机
9	男子 枪杀 妻子 后 自杀
10	医师 误 把 肾脏 当 肝脏 致人 身亡
11	癌症 老人 成功 手术
12	男子 枪杀 司机 后 喝药 自杀
13	癌症 医师 保持 手术 清醒
14	男子 跳楼 自杀
15	男子 枪杀 老人 后 自杀
16	消防员 冲进 火场 将 男童 救出
17	出租车 司机 免费 搭载 老人
18	男子 误 杀 弟媳 后 自杀 身亡
19	医师 误 把 患者 肝脏 捅破 致人 身亡
20	6旬 老人 火场 救人 不幸 身亡
```

## 代码实现

```python
# -*- coding: utf-8 -*-
__author__ = 'Wsine'

def loadDataSet(fileName):
	attrTemp = []
	with open(fileName) as fr:
		for line in fr.readlines()[1:]:
			words = line.strip().split('\t')[1].split()
			attrTemp.extend(words)
	attr = list(set(attrTemp))
	dataSet = []
	with open(fileName) as fr:
		for line in fr.readlines()[1:]:
			words = line.strip().split('\t')[1].split()
			data = []
			for word in words:
				for index, _word in enumerate(attr):
					if word == _word:
						data.append(index)
						break
			dataSet.append(data)
	return dataSet, attr

def createC1(dataSet):
	"""
	输入：数据集
	输出：所有大小为1的候选项集合C1
	"""
	C1 = []
	for transaction in dataSet:
		for item in transaction:
			if not [item] in C1:
				C1.append([item])
	C1.sort()
	return list(map(frozenset, C1))

def scanD(D, Ck, minSupport):
	"""
	输入：数据集集合, 候选项集, 最小支持度
	输出：最频繁项集的支持度
	"""
	ssCnt = {}
	for tid in D:
		for can in Ck:
			if can.issubset(tid):
				if not can in ssCnt:
					ssCnt[can] = 1
				else:
					ssCnt[can] += 1
	numItems = float(len(D))
	retList = []
	supportData = {}
	for key in ssCnt:
		support = ssCnt[key] / numItems
		if support >= minSupport:
			retList.insert(0, key)
		supportData[key] = support
	return retList, supportData

def aprioriGen(Lk, k):
	"""
	输入：频繁项集列表, 项集元素个数
	输出：合并后的项集列表
	"""
	retList = []
	lenLk = len(Lk)
	for i in range(lenLk):
		for j in range(i+1, lenLk):
			L1 = list(Lk[i])[:k-2]
			L2 = list(Lk[j])[:k-2]
			L1.sort()
			L2.sort()
			if L1 == L2:
				retList.append(Lk[i] | Lk[j])
	return retList

def apriori(dataSet, minSupport=0.5):
	"""
	输入：数据集, 最小支持度
	输出：候选项集列表
	"""
	C1 = createC1(dataSet)
	D = list(map(set, dataSet))
	L1, supportData = scanD(D, C1, minSupport)
	L = [L1]
	k = 2
	while (len(L[k-2]) > 0):
		Ck = aprioriGen(L[k-2], k)
		Lk, supK = scanD(D, Ck, minSupport)
		supportData.update(supK)
		L.append(Lk)
		k += 1
	return L, supportData

def calcConf(freqSet, H, supportData, br1, minConf=0.7):
	"""
	输入：频繁项集, 所有项集, 支持度数据, 通过检查的bigRuleList, 最小置信度
	输出：满足最小置信度要求的规则列表
	"""
	prunedH = []
	for conseq in H:
		conf = supportData[freqSet] / supportData[freqSet - conseq]
		if conf >= minConf:
			#print(freqSet - conseq, '-->', conseq, 'conf:', conf)
			br1.append((freqSet - conseq, conseq, conf))
			prunedH.append(conseq)
	return prunedH

def rulesFromConseq(freqSet, H, supportData, br1, minConf=0.7):
	"""
	输入：频繁项集, 所有项集, 支持度数据, 通过检查的bigRuleList, 最小置信度
	描述：生成更多的关联规则
	"""
	m = len(H[0])
	if (len(freqSet) > (m + 1)):
		Hmp1 = aprioriGen(H, m + 1)
		Hmp1 = calcConf(freqSet, Hmp1, supportData, br1, minConf)
		if (len(Hmp1) > 1):
			rulesFromConseq(freqSet, Hmp1, supportData, br1, minConf)

def generateRules(L, supportData, minConf=0.7):
	"""
	输入：频繁项集列表, 包含频繁项集支持数据的字典, 最小置信度
	输出：置信度规则列表
	"""
	bigRuleList = []
	for i in range(1, len(L)):
		for freqSet in L[i]:
			H1 = [frozenset([item]) for item in freqSet]
			if (i > 1):
				rulesFromConseq(freqSet, H1, supportData, bigRuleList, minConf)
			else:
				calcConf(freqSet, H1, supportData, bigRuleList, minConf)
	return bigRuleList

def printRules(rules, attr):
	for rule in rules:
		ruleFrom = []
		ruleFromSet = set(rule[0])
		while len(ruleFromSet) > 0:
			ruleFrom.append(attr[ruleFromSet.pop()])
		ruleTo = []
		ruleToSet = set(rule[1])
		while len(ruleToSet) > 0:
			ruleTo.append(attr[ruleToSet.pop()])
		print(ruleFrom, '-->', ruleTo)
		print('\tconf: ', rule[-1])

def main():
	dataSet, attr = loadDataSet('Apriori.txt')
	L, supportData = apriori(dataSet, minSupport=0.2)
	print('二项集', L[1])
	print('三项集', L[2])
	rules = generateRules(L, supportData, minConf=0.2)
	printRules(rules, attr)

if __name__ == '__main__':
	main()
```

## 输出样例

```
二项集 [frozenset({32, 39}), frozenset({32, 46}), frozenset({46, 39})]
三项集 [frozenset({32, 46, 39})]
['自杀'] --> ['男子']
        conf:  0.8571428571428572
['男子'] --> ['自杀']
        conf:  1.0
['后'] --> ['男子']
        conf:  0.8
['男子'] --> ['后']
        conf:  0.6666666666666667
['自杀'] --> ['后']
        conf:  0.5714285714285715
['后'] --> ['自杀']
        conf:  0.8
['自杀'] --> ['男子', '后']
        conf:  0.5714285714285715
['后'] --> ['男子', '自杀']
        conf:  0.8
['男子'] --> ['后', '自杀']
        conf:  0.6666666666666667
```