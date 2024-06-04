extends Control

var dicFile = "res://dictionary.json"
var hiraFile = "res://hiragana.json"
var kataFile = "res://katakana.json"

var dictionryDic : Dictionary
var hiraDic : Dictionary
var kataDic : Dictionary

var miniList = ["ャ","ュ","ョ","ェ","ォ","ゥ","ァ"] #ッ

var colorList = ["green","white","red","blue","yellow"]

var kanaOutput
var kanaPerms

var regex = RegEx.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	regex.compile("[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf\u3400-\u4dbf]")
	var stri = 'asa'
	stri[1] = 'a'
	print(stri)
	#var stri = 'asdfghjkl'
	#print(stri[-1])
	#var dicy = {1:'d',2:'3',4:'p',5:"ggd"}
	#for i in 1000:
		#print(dicy)
	#var array1 = ["One", 2]
	#var array2 = [3, "Four"]
	#array1.reverse()
	#print(array1)
	#print(array1 + array2) # ["One", 2, 3, "Four"]
	
	var json_as_text = FileAccess.get_file_as_string(hiraFile)
	hiraDic = JSON.parse_string(json_as_text)
	#if hiraDic:
		#print(hiraDic)
	
	json_as_text = FileAccess.get_file_as_string(kataFile)
	kataDic = JSON.parse_string(json_as_text)
	#if kataDic:
		#print(kataDic)
	
	json_as_text = FileAccess.get_file_as_string(dicFile)
	dictionryDic = JSON.parse_string(json_as_text)
	#if dictionryDic:
		#print(dictionryDic
	#var test = "辞書翻訳者に何を尋ねるかのようなものです。 ここではダークソウルについて話していると思うので、悪魔とたわごとは確実に火になります"
	#test = test.reverse()
	#test.substr(1)
	#print(test)
	#var test ='hello'
	#for i in test:
		#print(i)
	kanaOutput = $VBoxContainer/HBoxContainer/kanaOutput
	kanaPerms = $VBoxContainer/HBoxContainer/kanaPerms

func _process(delta):
	pass

func _on_text_edit_text_changed():
	var word = $VBoxContainer/TextEdit.text
	kanaOutput.text = ''
	kanaPerms.text = ''
	$VBoxContainer/dictionaryOutput.text = ''
	
	#~~~~~~~~~~~~~~~~~~~~~pink section~~~~~~~~~~~~~~~~~~~~~~~~~
	var book = dicCheck(word)
	var bookword = ''
	if not(book == {}):
		#print(book)
		for i in book:
			var tempword = i + ' : '
			for j in book[i]:
				#printt(i,j)
				tempword += j + ' '
			tempword += '\n'
			bookword = tempword + bookword
		$VBoxContainer/dictionaryOutput.text = bookword
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~blue section~~~~~~~~~~~~~~~~~~
	#var testy = regex.search()				#checkinf if a JP character
	var wordList = splitWord(word)
	#print(wordList)
	var original = ''
	var translation = ''
	var lastLetter = ''
	var currentWord = ''
	for i in wordList:
		#printt(i,typeTest(i))
		lastLetter = translation.right(1)
		original += '[color=' + colorList[0] + ']'
		translation += '[color=' + colorList[0] + ']'
		original += i
		#print(typeTest(i[0]))
		match (typeTest(i[0])):
			'nonJP':
				translation += i
				kanaPerms.text += i
			'hira':
				#print('reached')
				if i =="の":
					translation += "'s " #add an 'and' clause
				else:
					for j in i:
						translation += hiraDic[j]
						currentWord += hiraDic[j]
				kanaPerms.text += normalizeWord(currentWord)
				
			'kata':
				var templist = []
				for j in len(i):
					#printt(i[j], templist)
					if (i[j] in miniList) and not (j == 0):
						var poppy = kataDic.find_key(templist.pop_back())
						templist.append(kataDic[poppy+i[j]])
					elif i[j] == 'ッ':
						pass
					#if (i[j] in miniList) and (j == 0):
						#templist.append('this is nonsense,fix your input')
					else:
						templist.append(kataDic[i[j]])
				for j in templist:
					translation += j
					currentWord += j
				kanaPerms.text += normalizeWord(currentWord)
					#print(tempword)
					#if j in miniList:
						#var prev = tempword[-1]
						#tempword = tempword.left(-1)
						#
						#tempword += kataDic[prev + j]
					#else:
						#tempword += kataDic[j]
				#
				#translation += tempword
					#printt(j, kataDic[j])
			'kanji':
				var results = dicCheck(i)
				for j in results:
					translation += results[j][0] + ' '
					kanaPerms.text += results[j][0] + ' '
				if i == 'ー':
					translation += lastLetter
				elif results == {}:
					translation += '❌'
					kanaPerms.text += '❌'
				
				#if i in dictionryDic.keys:
					#translation += dictionryDic[i]
				#else:
					#var tempword = ''
					#for j in i:
						#tempword += j
						#if tempword in dictionryDic.keys:
							#translation += dictionryDic[tempword]
							#tempword = ''
					#if tempword
					
		currentWord = ''
		colorList.push_back(colorList.pop_front())
	kanaOutput.text = original + '\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n' + translation
	#print(kanaOutput.text)

func normalizeWord(word):
	print(word)
	var vowels = ['a','e','i','o','u']
	#u to space after consonent
	#get rid of vowels after d
	#r to l, version wih both
	#get rid of vowel at the end of term
	#ou to oh
	word = word.replace('ou','oh')
	#print(word.right(1))
	#if word.right(1) in vowels:
		#word = word.erase(word.length() - 1, 1)
		#print('IT HAPPENED')
	word = word.replace('r','l')
	word = word.replace('do','d')
	word = word.replace('du','d')
	
	
	var seeker = word.find('u')
	while seeker > -1:
		#print(word, seeker)
		if (seeker == 0) or (word[seeker - 1] in vowels):
			seeker += 1
		else:
			word[seeker] = ' '
			seeker = word.find('u', seeker)
	#print('new: ',word)
	return word

func splitWord(word):#hira,kata,kanji,nonJP
	var result = []
	var current = ''
	for i in word:
		
		if (current == '') or (typeTest(current.left(1)) == typeTest(i)):
			current += i
		else:
			result.append(current)
			current = i
		#printt(i, current, typeTest(i), typeTest(current.left(1)))
	if not current == '':
		result.append(current)
	return result

func typeTest(word):
	var testy = regex.search(word)
	if not testy:
		return 'nonJP'
	else:
		if word in hiraDic:
			return 'hira'
		if (word in kataDic) or (word in miniList):
			return 'kata'
		else:
			return 'kanji'

func dicCheck(book):
	var results = {}
	for i in dictionryDic:
		if book.count(i) > 0:
			results[i] = dictionryDic[i]
	return results

func _on_check_button_pressed():
	$VBoxContainer/reminder.visible = not $VBoxContainer/reminder.visible
