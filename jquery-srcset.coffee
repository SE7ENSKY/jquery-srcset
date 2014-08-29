parseSrcset = (srcset) ->
	srcset = srcset.split ","
	(for specString in srcset
		specStringParts = specString.replace(/^\s*/, "").replace(/\s*$/, "").split(" ")
		spec =
			url: specStringParts.shift()
		for specStringPart in specStringParts
			if specStringPart.match ///^\d+w$///
				spec.width = parseInt specStringPart
			else if specStringPart.match ///^\d+h$///
				spec.height = parseInt specStringPart
			else if specStringPart.match ///^\d+x$///
				spec.pixelDepth = parseInt specStringPart
		spec
	)
matchSrcset = (srcset, windowWidth, windowHeight, pixelDepth) ->
	matched = null
	matchedRange = 0
	for spec in srcset
		continue if spec.width and windowWidth > spec.width
		continue if spec.height and windowHeight > spec.height
		continue if spec.pixelDepth and pixelDepth < spec.pixelDepth
		range = 0
		range += 10 if spec.width
		range += 10 if spec.height
		range += 40 if spec.pixelDepth
		continue if range < matchedRange
		if matched and range is matchedRange
			arbitratorRange = 0
			if spec.width and matched.width and spec.width isnt matched.width
				arbitratorRange += if spec.width < matched.width then 1 else -1
			if spec.height and matched.height and spec.height isnt matched.height
				arbitratorRange += if spec.height < matched.height then 1 else -1
			if spec.pixelDepth and matched.pixelDepth and spec.pixelDepth isnt matched.pixelDepth
				arbitratorRange += if spec.pixelDepth > matched.pixelDepth then 1 else -1
			continue if arbitratorRange < 0
		spec.range = range
		matched = spec
		matchedRange = range
	if matched
		matched.url
	else
		null

processSrcset = ->
	windowWidth = $(window).width()
	windowHeight = $(window).height()
	pixelDepth = window.devicePixelRatio or 1

	$("img[srcset]").each ->
		srcset = parseSrcset $(@).attr("srcset")
		matched = matchSrcset srcset, windowWidth, windowHeight, pixelDepth
		$(@).attr "src", matched if matched

# testSrcset = ->
# 	tests = [
# 		['url1 500w, url0', 400, 1, 1, 'url1']
# 		['url1 300w, url0', 400, 1, 1, 'url0']
# 		['url1 500w, url2 300w, url0', 400, 1, 1, 'url1']
# 		['url1 500w, url2 300w, url3 2x, url0', 400, 1, 2, 'url3']
# 		['url1 500w 2x, url2 300w, url3 2x, url0', 400, 1, 2, 'url1']
# 		['url1 500w, url2 300w, url3 400h, url0', 400, 300, 1, 'url3']
# 		['url1 500w 2x, url2 300w, url3 400h, url0', 400, 300, 2, 'url1']
# 		['url1 500w 2x, url2 300w, url3 400h, url0', 400, 300, 1, 'url3']
# 		['url1 500w 2x, url2 300w, url3 400h, url0', 400, 500, 1, 'url0']
# 		['url1 500w 2x, url2 300w, url3 400h, url0', 200, 500, 1, 'url2']
# 		['url1 500w 2x, url2 300w 200h, url3 400h 500w, url0', 400, 300, 1, 'url3']
# 		['url1 500w 2x, url2 300w 200h, url3 400h 500w, url0', 200, 100, 1, 'url2']
# 		['url1 500w 2x, url2 300w 200h, url3 400h 500w, url0', 400, 300, 2, 'url1']
# 		['url1 500w 2x, url2 300w 200h, url3 400h 500w, url0', 400, 100, 1, 'url3']
# 		['url1 500w 2x, url2 300w 200h, url3 400h 500w, url0', 600, 100, 1, 'url0']
# 		['url1 500w 2x, url2 300w 900h, url3 800w 200h, url0', 600, 100, 1, 'url3']
# 		['url1 500w 2x, url2 300w 900h, url3 800w 200h, url0', 200, 100, 1, 'url3']
# 		['url1 500w 2x, url2 300w 900h, url3 800w 200h, url0', 200, 500, 1, 'url2']
# 	]
# 	for test in tests
# 		srcset = parseSrcset test[0]
# 		result = matchSrcset srcset, test[1], test[2], test[3]
# 		s = "'#{test[0]}' on #{test[1]}x#{test[2]}@#{test[3]}x -> #{test[4]}}"
# 		if result is test[4]
# 			console.log "OKAY #{s}"
# 		else
# 			console.log "FAIL #{s}, result is #{result}"
# 			console.log srcset

$ ->
	processSrcset()
	$(window).resize processSrcset
