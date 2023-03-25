
proc lua  restart ;
submit;
str=sas.symget("yticks")
view=sas.symget("ymargin")

tbl={}
rev={}
asc=""
des=""
out=""

-- string is separated by space and the numeric is assigned to table

for i in string.gmatch(str, "([^ ]+)") do

	if string.find(i, "^-?%d+%.?%d*$")~=nil then
		table.insert(tbl,tonumber(i))
	else
		print("ERROR: yticks is incorrect")
		sas.symput('stop', 1)
		goto exit
	end
end

-- numeric is assigned to table by reverse order and invert sign
flg=1
for n = 1, #tbl  do

	if tbl[n]~=0  then
		table.insert(rev, tonumber("-" .. tbl[n]))
		
	else 
		flg=0
	end

end

table.sort(tbl)
table.sort(rev, function(a,b) return a < b end)

-- generate text
asc=table.concat(tbl ," ")
des=table.concat(rev," ")

-- get the max and min number and generate view range
sas.symput('max_view', math.max(table.unpack(tbl))*view)
sas.symput('min_view', math.min(table.unpack(rev))*view)

-- if input string is not contained "0", add text
if flg==1 then
	out = des .. " 0 " .. asc
else
	out = des .. "  " .. asc
end

-- macro variable
sas.symput('yticks', out)

::exit::
endsubmit;
run;
