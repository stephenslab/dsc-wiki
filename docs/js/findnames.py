import glob,os
import json
import re

path="../docs"

def fileDict(docFile,folder):
	docString="var "+folder+"Dict={"
	for file in sorted(glob.glob(path+"/src/"+folder+"/*.ipynb")):
		name=file.replace(".ipynb","").split("/")[-1]
		with open(file) as json_data:
 			d=json.load(json_data)
 			title=d["cells"][0]["source"][0].replace(" ","-")[2:]+"-1"
 		# title=d["cells"]
		docString+='"'+title+'":"'+name+'",'
	docString=docString[:-1]
	docString+="}"
	# print (docString)
	docFile.write(docString+"\n")


def findImages(docFile):
	docString="var images=["
	for file in glob.glob(path+"/img/*"):
		name=file.split("/")[-1]
		docString+='"'+name+'",'
	docString=docString.rstrip(',') + ']'
	docFile.write(docString+"\n")


with open(path+"/src/homepage/documentation.ipynb") as json_data:
 	d_doc=json.load(json_data)
with open(path+"/src/homepage/tutorials.ipynb") as json_data:
 	d_tut=(json.load(json_data))


tutString="var tutorials=["
docString="var documentation=["
for cell in d_doc["cells"]:
	for sentence in cell["source"]:
		doc=re.search('doc/documentation/(.+?).html',sentence)
		if doc:
			name=doc.group(1)
			docString+='"'+name+'", '
for cell in d_tut["cells"]:
	for sentence in cell["source"]:
		tut=re.search('doc/tutorials/(.+?).html',sentence)
		if tut:
			name=tut.group(1)
			tutString+='"'+name+'", '

tutString=tutString.rstrip().rstrip(',') + ']'
docString=docString.rstrip().rstrip(',') + ']'


# print(tutString)
# print(docString)

docFile=open("../docs/js/docs.js","w")
#docFile=open("docs.js","w")
fileDict(docFile,"documentation")
fileDict(docFile,"tutorials")
findImages(docFile)

docFile.write(docString+"\n")
docFile.write(tutString+"\n")
docFile.close()
