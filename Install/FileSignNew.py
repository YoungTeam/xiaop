import urllib2
from poster.encode import multipart_encode
from poster.streaminghttp import register_openers
class SESigner:
	def __init__(self):
		self.username = "yangting"
		self.pwd = "youngteam@1982"
	def sign_file(self, path):
		register_openers()
		datagen, headers = multipart_encode({'data': open(path, 'rb').read(),'user' : self.username, 'pwd':self.pwd, 'signname':'yt'})
		#data = {"user" : self.username, "pwd" : self.pwd, "data" : open(path, "rb").read(), 'signname' : 'yt'}
		try:
			#print data
			#postData = urllib.urlencode(data);
			req = urllib2.Request("http://sign.yt-inc.com/sign3.php", datagen, headers);	
			content_stream = urllib2.urlopen(req)
			if content_stream == None:
				print "None"
				return False
			data = content_stream.read()
			if data.find('e_') == 0:
				print data
				return False
			outfile = open(path, "wb")
			outfile.write(data)
			outfile.close()
		except Exception,ex:
			print ex
			return False
		return True

if __name__ == "__main__":
	s = SESigner()
	s.sign_file("D:\\workspace\\C#\\XiaoP\\Install\\Pandora_3.0.0.1.exe")
	exit(0)
