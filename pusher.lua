local underscore = require('underscore')

local send = function(appid, authkey, authsecret, channelid, eventname, message, cluster)
	local parameters = {auth_version='1.0', auth_key=authkey, auth_timestamp=os.time(),
			body_md5=crypto.md5(message).hexdigest(), name=eventname}
	local url = string.format('/apps/%s/channels/%s/events', appid, channelid)
	parameters['auth_signature'] = crypto.hmac(
		authsecret, string.format(
			'POST\n%s\n%s', url,
			underscore.join(
				underscore.map(
					underscore.sort(underscore.keys(parameters)),
					function (k) return k..'='..parameters[k] end
				),
				'&'
			)),
		crypto.sha256).hexdigest()
	local subdomain = 'api'
	if cluster ~= nil then
		subdomain = subdomain .. "-" .. cluster
	end
	return http.request { method='post', url=string.format('https://%s.pusher.com%s?%s', subdomain,
		url, http.qsencode(parameters)), data=message }
end

return {send=send}
