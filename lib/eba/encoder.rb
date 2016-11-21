# This enforces that a string is encoded in UTF-8
class Encoder
	def encode(string)
		return string.encode("utf-8")
	end
end
