
from face_recognition import load_image_file, face_encodings, compare_faces,face_distance
from flask import Flask
from flask_restful import Resource, Api
from glob import iglob
from itertools import compress
import math
import json
import base64
from itertools import compress
from flask import request, jsonify

app = Flask(__name__)
api = Api(app)
known_encoding=[]
known_paths=[]
class imagematch(Resource):
	def post(self):
		unencoding = []
		json_data = request.get_json(force=True)
		image = json_data['image']
		tolerance = json_data['tolerance']
		imgdata = base64.b64decode(str(image))
		filename = 'filename'
		with open(filename,'wb') as f:
			f.write(imgdata)	
		known_image = load_image_file('path to file')
		unencodings = face_encodings(known_image)	
		if len(unencodings)>=1:
			unencoding.append(unencodings[0])
			print('encoded')
		paths , distance = match_faces(known_encoding,unencoding,tolerance)	
		bod = {'images':paths,'accuracy':distance}
		print(bod)
		return {'image':f'{paths}','accuracy':f'{distance}','result':f'{len(distance)}'}
		

	
def encode_dir(dirpath):   
    glob_path = dirpath.rstrip('/') + '/*'
    encoding = []
    paths = []    
    for path in iglob(glob_path):
        try:
            images = load_image_file(path)
            encodings = face_encodings(images)
            print('encoded')
            if len(encodings) >= 1:
                encoding.append(encodings[0])
                paths.append(path)
        except Exception as e:
            print(e)
    print(len(encoding),len(paths))
    return encoding, paths

def match_faces(known_dir, unknown_dir,tolerance):
	paths_matched=[]
	distance_from=[]
	for unknown_encoding in unknown_dir:
		compare_mask = compare_faces(known_dir, unknown_encoding,tolerance)
		distances = face_distance(known_dir, unknown_encoding)
		paths_matched_with_unknown_encoding = list(compress(known_paths, compare_mask))
		distances_from_unknown_encodings = list(compress(distances, compare_mask))
	for pat in paths_matched_with_unknown_encoding:
		with open(pat,"rb") as imageFile:
			str = base64.b64encode(imageFile.read())
			paths_matched.append(str)
	for dist in distances_from_unknown_encodings:
		distance_from.append(dist)
	return paths_matched,distance_from

api.add_resource(imagematch,'/image')

known_encoding ,known_paths =encode_dir('path to directory')
if __name__ =='__main__':
	app.run(debug=,host='',port='')	
	

		
