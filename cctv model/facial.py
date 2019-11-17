import face_recognition
import cv2
import numpy as np
import smtplib,ssl


   
location ="Lat- 18.528851,Long- 73.859207"
en=[]
fen=[]
details= None


video_capture = cv2.VideoCapture(0)
obama_image = face_recognition.load_image_file("obama.jpg")
obama_face_encoding = face_recognition.face_encodings(obama_image)[0]
biden_image = face_recognition.load_image_file("biden.jpg")
biden_face_encoding = face_recognition.face_encodings(biden_image)[0]
mitul = face_recognition.load_image_file("mitul.jpg")
mitul_face_encoding = face_recognition.face_encodings(mitul)[0]
a1 = face_recognition.load_image_file("1.jpg")
a1_face_encoding = face_recognition.face_encodings(a1)[0]
a2 = face_recognition.load_image_file("2.jpg")
a2_face_encoding = face_recognition.face_encodings(a2)[0]
a3 = face_recognition.load_image_file("3.jpg")
a3_face_encoding = face_recognition.face_encodings(a3)[0]
a4 = face_recognition.load_image_file("4.jpg")
a4_face_encoding = face_recognition.face_encodings(a4)[0]
a5 = face_recognition.load_image_file("5.jpg")
a5_face_encoding = face_recognition.face_encodings(a5)[0]




known_face_encodings = [
    obama_face_encoding,
    biden_face_encoding,
    mitul_face_encoding,
    a1_face_encoding,
    a2_face_encoding,
    a3_face_encoding,
    a4_face_encoding,
    a5_face_encoding,
]





# Initialize some variables
face_locations = []
face_encodings = []
face_names = []
process_this_frame = True
w=0
while True:
    
    
    ret, frame = video_capture.read()

    small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)

    rgb_small_frame = small_frame[:, :, ::-1]


    if process_this_frame:
       
        face_locations = face_recognition.face_locations(rgb_small_frame)
        face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)

        face_names = []
        for face_encoding in face_encodings:
           
            matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
            name = "Unknown"

            face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
            print(face_distances)
            best_match_index = np.argmin(face_distances)
            print(best_match_index)
            if matches[best_match_index]:
                name = 'known person'
                details = name
                print(w)
            if(details!=None and w<1):
                import smtplib
                w+=1
                print("after mail",w)
                

                gmail_user = 'ajaywikebullhog@gmail.com'
                gmail_password = 'ohyluetghplwswwb'

                sent_from = gmail_user
                to = ['ajaypratap9980@gmail.com']
                subject = 'Find Missing Person'
                body ="A Suspicious/Missing person has been found at location "+ location 

                email_text = """\
                From: %s
                To: %s
                Subject: %s

                %s
                """ % (sent_from, ", ".join(to), subject, body)

                try:
                    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
                    server.ehlo()
                    server.login(gmail_user, gmail_password)
                    server.sendmail(sent_from, to, email_text)
                    server.close()
                    

                
                except:
                    print ('Something went wrong...')
                details = None

                
          

            face_names.append(name)

    process_this_frame = not process_this_frame


    
    for (top, right, bottom, left), name in zip(face_locations, face_names):
       
        top *= 4
        right *= 4
        bottom *= 4
        left *= 4

       
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 0, 255), 2)

        cv2.rectangle(frame, (left, bottom - 35), (right, bottom), (0, 0, 255), cv2.FILLED)
        font = cv2.FONT_HERSHEY_DUPLEX
        cv2.putText(frame, name, (left + 6, bottom - 6), font, 1.0, (255, 255, 255), 1)

 
    cv2.imshow('Video', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release handle to the webcam
video_capture.release()
cv2.destroyAllWindows()