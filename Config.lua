-- Config.Lua for configuration of LuaTiddly
--CURRDIR = "Test"
CURRDIR = "../../../../../../../../Startup/Neukleus/Website/"

TEMPLATE = "template.html"

OUTDIR = "C:/Users/milindgupta/Documents/outputNeukleus"

BASEURL = "http://www.neukleus.com"

FILES2EXCLUDE = {
					"searchResults.html",
					"NEUKLEUS.html",
					"template.html"
}

EXTDOCS = "docs"

-- Function to add the equation tags to include the jqMath script to the HTML file
function addEqnTags(divID,val,html)
	local head,st,pt,swt,pwt
	head,st,pt,swt,pwt = getTagString(html,"head",{})
	html = html
end

-- Function to generate the Recent articles list in the home page
function recentA()
	-- Extensions to process
	local ext = ext or {"html","htm"}
	-- Add the template file in FILES2EXCLUDE list
	if LT.config.FILES2EXCLUDE then
		LT.config.FILES2EXCLUDE[#LT.config.FILES2EXCLUDE + 1] = LT.config.TEMPLATE
	else
		LT.config.FILES2EXCLUDE = {LT.config.TEMPLATE}
	end
	local articles = {}

	for file in lfs.dir(lfs.currentdir()) do
		-- Check if file is a file
		if lfs.attributes(file,"mode") == "file" then
			-- Check if the file extension matches the extensions to process
			local fileExt = file:match("%.([%w_]+)$")
			local match = false
			for i,v in ipairs(ext) do
				if v == fileExt then
					match = true
					break
				end
			end
			if match then
				-- File matches extension				
				-- Check if the file is not in the list of files to exclude
				match = false
				for i,v in ipairs(LT.config.FILES2EXCLUDE) do
					if file == v then
						match = true
						break
					end
				end
				if not match then
					-- Read the tiddler file
					local var1 = io.open(file,"r")
					local srcFile = var1:read("*all")
					var1:close()
					-- Get the text inside the div element with class viewer
					local divSub = getTagString(srcFile,"div",{class="subtitle"}, true)
					if divSub then
						local dt,mnt,yr, strDate, text
						local mntTab = {January="01", February="02", March="03", April="04", May="05", June="06", July="07", August="08", September="09", October="10", November="11", December="12"}
						_,_,dt,mnt,yr = divSub:find("([0123]*%d) (%u%l%l+) (%d%d%d%d)")
						if #dt == 1 then
							dt = "0"..dt
						end
						strDate = yr..mntTab[mnt]..dt
						text = ""
						-- Now get the article text
						local divSub = getTagString(srcFile,"div",{class="viewer"}, true)
						if divSub then
							-- Remove the table of content header if any
							local div1,st,swt,pt,pwt
							div1,st,pt,swt,pwt = getTagString(divSub,"div",{class="dcTOC"})
							if div1 then
								divSub = divSub:sub(pt+1,-1)
							end
							-- Nullify all HTML tags
							divSub = divSub:gsub("%>%<[^%>]-%>%<","><")
							divSub = divSub:gsub("%>%<[^%>]-%>",">")
							divSub = divSub:gsub(" %<[^%>]-%> "," ")
							divSub = divSub:gsub("(%S)%<[^%>]-%>(%S)","%1:%2")
							divSub = divSub:gsub("%<[^%>]-%>","")
							divSub = divSub:gsub("%[top%]","")
							if divSub and #divSub>50 then
								text = divSub:sub(1,50).."..."
							elseif divSub then
								text = divSub:sub(1,50)
							end
						end
						articles[#articles + 1] = {Title = file:sub(1,-(#fileExt+2)), Date = strDate, Text = text}
					end
				end
			end
		end
	end		-- for file in lfs.dir(lfs.currentdir()) do ends here
	-- Sort the articles here
	for i = 1,#articles-1 do
		for j = 1,#articles-i do
			if tonumber(articles[j].Date) < tonumber(articles[j+1].Date) then
				-- Swap them
				local buf = articles[j+1]
				articles[j+1] = articles[j]
				articles[j] = buf
			end
		end
	end
	local htmlText = "<h3>Recent Articles:</h3> <big>"
 --[[<h3>Recent Articles:</h3> <big><a href="www.amved.com">Article 1</a><br>
      <small>Article 1 Text</small><br>
      <a href="www.amved.com">Article 2</a><br>
      </big><big><small>Article 2 Text</small></big><br>
      <big><a href="www.google.com">Article 3</a></big><br>
      <big><small>Article 3 Text</small></big> ]]
	  	
	local numOfArticles = 5
	if #articles < numOfArticles then
		numOfArticles = #articles
	end
	for i = 1,numOfArticles do
		htmlText = htmlText..[[<a href="]]..LT.config.BASEURL..[[/]]..articles[i].Title:gsub("%W","_").."."..LT.config.TEMPLATE:match("%.([%w_]+)$")..[[">]]..articles[i].Title..[[</a><br><small>]]..articles[i].Text..[[</small><br>]]
		--print(" TITLE: "..articles[i].Title.." DATE: "..articles[i].Date.." TEXT: "..articles[i].Text)
	end
	htmlText = htmlText.."</big>"
	return htmlText
end

LTMAP = {
    ["#TITLE"] = "Neukleus, Open source Home & Data automation: <LT>#ORIGPAGENAME</LT>",
	sideAd1 = [[<LT>#FUNC=recentA</LT>]],
	TiddlerTitle = "<LT>#ORIGPAGENAME</LT>",
    RecentA = "",
    myFloatBar = [[<div style="margin-right:30px;" class="fb-like" data-href="<LT>#PAGEURL</LT>" data-send="false" data-layout="button_count" data-width="450" data-show-faces="false"></div>
		<a href="https://twitter.com/share" class="twitter-share-button" data-hashtags="Neukleus">Tweet</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
<!-- Place this tag where you want the +1 button to render. -->
<div class="g-plusone" data-size="medium" data-annotation="inline" data-width="300"></div>

<script src="//platform.linkedin.com/in.js" type="text/javascript">
  lang: en_US
</script>
<script type="IN/Share" data-counter="right"></script>]],
    SocialM = [[<div style="margin-right:30px;" class="fb-like" data-href="<LT>#PAGEURL</LT>" data-send="false" data-layout="button_count" data-width="450" data-show-faces="false"></div>
						<a href="https://twitter.com/share" class="twitter-share-button" data-hashtags="Neukleus">Tweet</a>
				<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
				<!-- Place this tag where you want the +1 button to render. -->
				<div class="g-plusone" data-size="medium" data-annotation="inline" data-width="300"></div>

<!-- Place this tag after the last +1 button tag. -->
<script type="text/javascript">
  (function() {
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/platform.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
  })();
</script>
<script src="//platform.linkedin.com/in.js" type="text/javascript">
  lang: en_US
</script>
<script type="IN/Share" data-counter="right"></script>]]
    }

	
	
-- LTMAP table for the index file	
index = {
    ["#TITLE"] = "Neukleus, Open source Home & Data automation",
	TiddlerTitle = ""
}

