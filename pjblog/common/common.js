//PBlog2 公用JS代码
//Author:PuterJam

/***************************************
	重定义一些函数
****************************************/
  String.prototype.utf8 = function(){  
	  return encodeURIComponent(this.toString());
  }
  
  String.prototype.GB =function(){
	  return decodeURIComponent(this.toString()).replace(/\+/g," ");
  }
  
  String.prototype.reg = function(r){
	  return r.test(this.toString());
  };
  
  String.prototype.toNum = function(){
	  return parseInt(this.toString());
  };
  
  String.prototype.trim = function(){
	  return this.toString().replace(/^(\s+)|(\s+)$/,"");
  };
  
  String.prototype.json = function(){
	  try{eval("var jsonStr = (" + this.toString() + ")");}catch(ex){var jsonStr = null;}
	  return jsonStr;
  };
  
//复制提交内容
function CopyAll(A){
	A.focus() //使文本框得到焦点
	A.select() //把文本框中的内容全选
	if (document.all){
		therange=A.createTextRange()
		therange.execCommand("Copy") //复制
	}
}

function $(){ 
    var elements = new Array(); 
    for (var i = 0; i < arguments.length; i++) 
    { 
        var element = arguments[i]; 
        if (typeof element == 'string') 
            element = document.getElementById(element); 
        if (element) {
        } else {
            element = null;
        }
        if (arguments.length == 1) {
            return element; 
        } else {
            elements.push(element); 
        }
    } 
    return elements; 
}

//查找网页内宽度太大的图片进行缩放以及PNG纠正
 function ReImgSize(){
  for (i=0;i<document.images.length;i++)
   {
   if (document.all){
	if (document.images[i].width>550)
	 {
       document.images[i].width="550"
       try{
	       document.images[i].outerHTML='<a href="'+document.images[i].src+'" target="_blank" title="在新窗口打开图片">'+document.images[i].outerHTML+'</a>'
  	 	}catch(e){}
  	 }
   }
  else{
	if (document.images[i].width>400) {
	  document.images[i].title="在新窗口打开图片"
	  document.images[i].style.cursor="pointer"
	  document.images[i].onclick=function(e){window.open(this.src)}
	}
  }
  }
 }

//AccessKey 转换For IE Design By PuterJam
  var NKey=new Array()
  var KeyCode=new Array()
  var KeyInit=false
//======== keyCode ============
  KeyCode["1"]=49
  KeyCode["2"]=50
  KeyCode["3"]=51
  KeyCode["["]=219
  KeyCode["]"]=221
  KeyCode[","]=188
  KeyCode["."]=190
  var EKey="abcdefghijklmnopqrstuwvxyz"
  for (i=0;i<26;i++){
    KeyCode[EKey.substr(i,1)]=65+i
  }
  
  function PressKey(){
	 if (document.all) {
	   for (i=0;i<NKey.length;i++){
		   if (window.event.altKey && window.event.keyCode==NKey[i].Code) {NKey[i].Object.blur();NKey[i].Object.click()}
	   }

	}
  }
  
  function AccessKey(Code,Object){
   this.Code=Code
   this.Object=Object
  }


  function initAccessKey(){
	 if (document.all && !KeyInit) {
	    for (i=0;i<document.links.length;i++){
	      if (document.links[i].accessKey) {
	        NKey[NKey.length]=new AccessKey(KeyCode[document.links[i].accessKey.toLowerCase()],document.links[i])
	      }
	    }
	 }
	 KeyInit=true
  }

//初始化JS代码
function initJS(){
	ReImgSize() //自动缩放代码 
	initAccessKey()  //转换AccessKey For IE
}

//让Mozilla支持innerText
try{
	HTMLElement.prototype.__defineGetter__
	(
	"innerText",
	function ()
	{
		var anyString = "";

		var childS = this.childNodes;
			for(var i=0; i<childS.length; i++)
			{
				if(childS[i].nodeType==1)
				anyString += childS[i].tagName=="BR" ? '\n' : childS[i].innerText;
				else if(childS[i].nodeType==3)
				anyString += childS[i].nodeValue;
			}
			return anyString;
	}
	); 
}
catch(e){}

//判断是否是IE
function isIE(){
	if (navigator.appName!="Microsoft Internet Explorer") {return false}
	return true
}
//显示隐藏主题
function TopicShow(e,TopicID){
	 e.className=(e.className=="BttnC")?"BttnE":"BttnC"
	 document.getElementById(TopicID).style.display=(e.className=="BttnC")?"":"none"
	 ReImgSize()
}
//打开新窗口
function popnew(url,title,width,height){
    var w = 1024;
    var h = 768;

    if (document.all || document.layers){
        w = screen.availWidth;
        h = screen.availHeight;
    }

    var leftPos = (w/2-width/2);
    var topPos = (h/2.3-height/2.3);

    window.open(url,title,"width="+width+",height="+height+",top="+topPos+",left="+leftPos+",scrollbars=no,resizable=no,status=no")
}
//运行代码
function runEx(cod1)  {
	 cod=document.getElementById(cod1)
	  var code=cod.value;
	  if (code!=""){
		  var newwin=window.open('','','');  
		  newwin.opener = null 
		  newwin.document.write(code);  
		  newwin.document.close();
	}
}
//复制代码
function doCopy(ID) { 
	if (document.all){
		 textRange = document.getElementById(ID).createTextRange(); 
		 textRange.execCommand("Copy"); 
		 alert("代码已经复制到剪切板");
	}
	else{
		 alert("此功能只能在IE上有效\n\n请在文本域中用Ctrl+A选择再复制")
	}
}
//另存代码
function saveCode(ID) {
	 cod=document.getElementById(ID)
        var winname = window.open('','','width=0,height=0,top=1,left=1');
        winname.document.open('text/html', 'replace');
        winname.document.write(cod.value);
        winname.document.execCommand('saveas','','Code.htm');
        winname.close();
}
var MediaTemp=new Array()
function MediaShow(strType,strID,strURL,intWidth,intHeight)
{
	var tmpstr
	if (MediaTemp[strID]==undefined) MediaTemp[strID]=false; else MediaTemp[strID]=!MediaTemp[strID];
	if(MediaTemp[strID]){
			if ( document.all )	{
	         	document.getElementById(strID).outerHTML = '<div id="'+strID+'"></div>'
			}
			else
			{
	         	document.getElementById(strID).innerHTML = ''
			}

		document.images[strID+"_img"].src="images/mm_snd.gif" 		
		document.getElementById(strID+"_text").innerHTML="在线播放"	
	}else{
		document.images[strID+"_img"].src="images/mm_snd_stop.gif" 		
		document.getElementById(strID+"_text").innerHTML="关闭在线播放"
		switch(strType){
			case "swf":
				tmpstr='<div style="height:6px;overflow:hidden"></div><object codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="'+intWidth+'" height="'+intHeight+'"><param name="movie" value="'+strURL+'" /><param name="quality" value="high" /><param name="AllowScriptAccess" value="never" /><embed src="'+strURL+'" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="'+intWidth+'" height="'+intHeight+'" /></object>';
				break;
			case "wma":
				tmpstr='<div style="height:6px;overflow:hidden"></div><object classid="CLSID:22d6f312-b0f6-11d0-94ab-0080c74c7e95"  id="MediaPlayer" width="450" height="70"><param name=""showStatusBar" value="-1"><param name="AutoStart" value="False"><param name="Filename" value="'+strURL+'"></object>';
				break;
			case "wmv":
				tmpstr='<div style="height:6px;overflow:hidden"></div><object classid="clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95" codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,0,02,902" type="application/x-oleobject" standby="Loading..." width="'+intWidth+'" height="'+intHeight+'"><param name="FileName" VALUE="'+strURL+'" /><param name="ShowStatusBar" value="-1" /><param name="AutoStart" value="true" /><embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/" src="'+strURL+'" autostart="true" width="'+intWidth+'" height="'+intHeight+'" /></object>';
				break;
			case "rm":
				tmpstr='<div style="height:6px;overflow:hidden"></div><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="'+intWidth+'" height="'+intHeight+'"><param name="SRC" value="'+strURL+'" /><param name="CONTROLS" VALUE="ImageWindow" /><param name="CONSOLE" value="one" /><param name="AUTOSTART" value="true" /><embed src="'+strURL+'" nojava="true" controls="ImageWindow" console="one" width="'+intWidth+'" height="'+intHeight+'"></object>'+
                '<br/><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="'+intWidth+'" height="32" /><param name="CONTROLS" value="StatusBar" /><param name="AUTOSTART" value="true" /><param name="CONSOLE" value="one" /><embed src="'+strURL+'" nojava="true" controls="StatusBar" console="one" width="'+intWidth+'" height="24" /></object>'+'<br /><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="'+intWidth+'" height="32" /><param name="CONTROLS" value="ControlPanel" /><param name="AUTOSTART" value="true" /><param name="CONSOLE" value="one" /><embed src="'+strURL+'" nojava="true" controls="ControlPanel" console="one" width="'+intWidth+'" height="24" autostart="true" loop="false" /></object>';
				break;
			case "ra":
				tmpstr='<div style="height:6px;overflow:hidden"></div><object classid="clsid:CFCDAA03-8BE4-11CF-B84B-0020AFBBCCFA" id="RAOCX" width="450" height="60"><param name="_ExtentX" value="6694"><param name="_ExtentY" value="1588"><param name="AUTOSTART" value="true"><param name="SHUFFLE" value="0"><param name="PREFETCH" value="0"><param name="NOLABELS" value="0"><param name="SRC" value="'+strURL+'"><param name="CONTROLS" value="StatusBar,ControlPanel"><param name="LOOP" value="0"><param name="NUMLOOP" value="0"><param name="CENTER" value="0"><param name="MAINTAINASPECT" value="0"><param name="BACKGROUNDCOLOR" value="#000000"><embed src="'+strURL+'" width="450" autostart="true" height="60"></embed></object>';
				break;
			case "qt":
				tmpstr='<div style="height:6px;overflow:hidden"></div><embed src="'+strURL+'" autoplay="true" loop="false" controller="true" playeveryframe="false" cache="false" scale="TOFIT" bgcolor="#000000" kioskmode="false" targetcache="false" pluginspage="http://www.apple.com/quicktime/" />';
		}
		document.getElementById(strID).innerHTML = tmpstr;
	}
		document.getElementById(strID+"_href").blur()
}

function Trim(TRIM_VALUE){
	if(TRIM_VALUE.length < 1){
		return"";
	}
	TRIM_VALUE = RTrim(TRIM_VALUE);
	TRIM_VALUE = LTrim(TRIM_VALUE);
	if(TRIM_VALUE==""){
		return "";
	}
	else{
		return TRIM_VALUE;
	}
} //End Function

function RTrim(VALUE){
	var w_space = String.fromCharCode(32);
	var v_length = VALUE.length;
	var strTemp = "";
	if(v_length < 0){
		return"";
	}
	var iTemp = v_length -1;

	while(iTemp > -1){
		if(VALUE.charAt(iTemp) == w_space){
		}
		else{
			strTemp = VALUE.substring(0,iTemp +1);
			break;
		}
		iTemp = iTemp-1;

	} //End While
	return strTemp;

} //End Function

function LTrim(VALUE){
	var w_space = String.fromCharCode(32);
	if(v_length < 1){
		return"";
	}
	var v_length = VALUE.length;
	var strTemp = "";
	var iTemp = 0;

	while(iTemp < v_length){
		if(VALUE.charAt(iTemp) == w_space){
			}
			else{
				strTemp = VALUE.substring(iTemp,v_length);
				break;
		}
		iTemp = iTemp + 1;
	} //End While
	return strTemp;
} //End Function


function CheckPost(){
  try{
	if (Trim(document.forms[0].title.value)=="") {
		 alert("标题不能为空,请写日志标题!")
		 document.forms[0].title.focus()
		 return false
		}
	}
  catch(e){}

  try{
    if (document.getElementById("P2").checked) {
    	if (!CheckDate(document.forms[0].PubTime.value)){
    	   alert("日期格式不正确!\n格式:yyyy-mm-dd hh:mm:ss")	
		   return false
    	}
    	else
    	{
	    	document.forms[0].PubTime.value=CheckDate(document.forms[0].PubTime.value)
    	}
    }
  }
  catch(e){}

  try{
   if (GetMessageLength()==0){
		 alert("内容不能为空!")
		 return false
   }
  }
  catch(e){
	if (Trim(document.forms[0].Message.value)=="") {
		 alert("内容不能为空!")
		 try{document.forms[0].Message.focus()}catch(e){}
		 return false
	}
  }
   try{document.forms[0].SaveArticle.disabled=true}catch(e){}
   try{document.forms[0].SaveDraft.disabled=true}catch(e){}
   try{document.forms[0].ReturnButton.disabled=true}catch(e){}
   try{document.forms[0].CancelEdit.disabled=true}catch(e){e}
   try{document.forms[0].DelArticle.disabled=true}catch(e){}
   return true
}

   function CheckDate(str){
        var reg = /^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2}) (\d{1,2}):(\d{1,2}):(\d{1,2})$/; 
        var r = str.match(reg); 
        if(r==null)return false; 
        var d= new Date(r[1],r[3]-1,r[4],r[5],r[6],r[7]); 
        return (d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate()+" "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds());
   }

function GetMessageLength()
{
	var oEditor = FCKeditorAPI.GetInstance('Message') ;
	var oDOM = oEditor.EditorDocument ;
	var iLength ;

	if ( document.all )		// If Internet Explorer.
	{
		iLength = oDOM.body.innerText.length ;
	}
	else					// If Gecko.
	{
		var r = oDOM.createRange() ;
		r.selectNodeContents( oDOM.body ) ;
		iLength = r.toString().length ;
	}
//	oEditor.InsertHtml('');
	oEditor.Focus();
return iLength
}	

//FCK编辑器字数统计
function GetLength()
{
	alert( '当前字数: 共 ' + GetMessageLength() + ' 个字' ) ;
}

function SetContents()
{
	var oEditor = FCKeditorAPI.GetInstance('Message') ;
	oEditor.SetData( '' ) ;
	oEditor.Focus();
}

function SetFont(size){
	document.getElementById("logPanel").style.fontSize=size
}

//引用
function addQuote(usr,content){
	//try{
		if (document.getElementById("editorbody").style.display=="none") {
			loadUBB("Message");
		}
	    document.forms["frm"].Message.value="[quote="+usr+"]"+document.getElementById(content).innerText+"[/quote]"
		document.forms["frm"].Message.focus();
	//}catch(e){}
}

//插入上传附件
function addUploadItem(type,path,memberDown){
	var EditType=""
	try{
	  var oEditor = parent.FCKeditorAPI.GetInstance('Message')
	  EditType="FCkEditor"
	  var hrefLen=location.href.lastIndexOf("/")
      var Fhref=location.href.substr(0,hrefLen+1)
      path=Fhref+path
	}
	catch(e){
	  EditType="UBBEditor"
	}
	type=type.toLowerCase()
 	 switch(type){
 	  case 'gif':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[img]'+path+'[/img]\n'}
        else{oEditor.InsertHtml('<img src="'+path+'" alt=""/>')}
 	  	break;
 	  case 'jpg':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[img]'+path+'[/img]\n'}
        else{oEditor.InsertHtml('<img src="'+path+'" alt=""/>')}
 	  	break;
 	  case 'png':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[img]'+path+'[/img]\n'}
        else{oEditor.InsertHtml('<img src="'+path+'" alt=""/>')}
 	  	break;
 	  case 'bmp':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[img]'+path+'[/img]\n'}
        else{oEditor.InsertHtml('<img src="'+path+'" alt=""/>')}
 	  	break;
 	  case 'jpeg':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[img]'+path+'[/img]\n'}
        else{oEditor.InsertHtml('<img src="'+path+'" alt=""/>')}
 	  	break;
 	  case 'mp3':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[wma]'+path+'[/wma]\n'}
        else{oEditor.InsertHtml('<object classid="CLSID:22d6f312-b0f6-11d0-94ab-0080c74c7e95"  id="MediaPlayer" width="450" height="70"><param name=""showStatusBar" value="-1"><param name="AutoStart" value="False"><param name="Filename" value="'+path+'"></object>')}
 	  	break;
 	  case 'wma':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[wma]'+path+'[/wma]\n'}
        else{oEditor.InsertHtml('<object classid="CLSID:22d6f312-b0f6-11d0-94ab-0080c74c7e95"  id="MediaPlayer" width="450" height="70"><param name=""showStatusBar" value="-1"><param name="AutoStart" value="False"><param name="Filename" value="'+path+'"></object>')}
 	  	break;
 	  case 'rm':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[rm]'+path+'[/rm]\n'}
        else{oEditor.InsertHtml('<object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="400" height="300"><param name="SRC" value="'+path+'" /><param name="CONTROLS" VALUE="ImageWindow" /><param name="CONSOLE" value="one" /><param name="AUTOSTART" value="true" /><embed src="'+path+'" nojava="true" controls="ImageWindow" console="one" width="400" height="300"></object><br/><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="400" height="32" /><param name="CONTROLS" value="StatusBar" /><param name="AUTOSTART" value="true" /><param name="CONSOLE" value="one" /><embed src="'+path+'" nojava="true" controls="StatusBar" console="one" width="400" height="24" /></object><br/><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="400" height="32" /><param name="CONTROLS" value="ControlPanel" /><param name="AUTOSTART" value="true" /><param name="CONSOLE" value="one" /><embed src="'+path+'" nojava="true" controls="ControlPanel" console="one" width="400" height="24" autostart="true" loop="false" /></object>')}
 	  	break;
 	  case 'rmvb':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[rm]'+path+'[/rm]\n'}
        else{oEditor.InsertHtml('<object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="400" height="300"><param name="SRC" value="'+path+'" /><param name="CONTROLS" VALUE="ImageWindow" /><param name="CONSOLE" value="one" /><param name="AUTOSTART" value="true" /><embed src="'+path+'" nojava="true" controls="ImageWindow" console="one" width="400" height="300"></object><br/><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="400" height="32" /><param name="CONTROLS" value="StatusBar" /><param name="AUTOSTART" value="true" /><param name="CONSOLE" value="one" /><embed src="'+path+'" nojava="true" controls="StatusBar" console="one" width="400" height="24" /></object><br/><object classid="clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA" width="400" height="32" /><param name="CONTROLS" value="ControlPanel" /><param name="AUTOSTART" value="true" /><param name="CONSOLE" value="one" /><embed src="'+path+'" nojava="true" controls="ControlPanel" console="one" width="400" height="24" autostart="true" loop="false" /></object>')}
 	  	break;
 	  case 'ra':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[ra]'+path+'[/ra]\n'}
        else{oEditor.InsertHtml('<object classid="clsid:CFCDAA03-8BE4-11CF-B84B-0020AFBBCCFA" id="RAOCX" width="450" height="60"><param name="_ExtentX" value="6694"><param name="_ExtentY" value="1588"><param name="AUTOSTART" value="true"><param name="SHUFFLE" value="0"><param name="PREFETCH" value="0"><param name="NOLABELS" value="0"><param name="SRC" value="'+path+'"><param name="CONTROLS" value="StatusBar,ControlPanel"><param name="LOOP" value="0"><param name="NUMLOOP" value="0"><param name="CENTER" value="0"><param name="MAINTAINASPECT" value="0"><param name="BACKGROUNDCOLOR" value="#000000"><embed src="'+path+'" width="450" autostart="true" height="60"></embed></object>')}
 	  	break;
 	  case 'asf':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[wmv]'+path+'[/wmv]\n'}
        else{oEditor.InsertHtml('<object classid="clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95" codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,0,02,902" type="application/x-oleobject" standby="Loading..." width="400" height="300"><param name="FileName" VALUE="'+path+'" /><param name="ShowStatusBar" value="-1" /><param name="AutoStart" value="true" /><embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/" src="'+path+'" autostart="true" width="400" height="300" /></object>')}
 	  	break;
 	  case 'avi':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[wmv]'+path+'[/wmv]\n'}
        else{oEditor.InsertHtml('<object classid="clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95" codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,0,02,902" type="application/x-oleobject" standby="Loading..." width="400" height="300"><param name="FileName" VALUE="'+path+'" /><param name="ShowStatusBar" value="-1" /><param name="AutoStart" value="true" /><embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/" src="'+path+'" autostart="true" width="400" height="300" /></object>')}
 	  	break;
 	  case 'wmv':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[wmv]'+path+'[/wmv]\n'}
        else{oEditor.InsertHtml('<object classid="clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95" codebase="http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=6,0,02,902" type="application/x-oleobject" standby="Loading..." width="400" height="300"><param name="FileName" VALUE="'+path+'" /><param name="ShowStatusBar" value="-1" /><param name="AutoStart" value="true" /><embed type="application/x-mplayer2" pluginspage="http://www.microsoft.com/Windows/MediaPlayer/" src="'+path+'" autostart="true" width="400" height="300" /></object>')}
 	  	break;
 	  case 'swf':
        if (EditType=="UBBEditor"){parent.document.forms[0].Message.value+='[swf]'+path+'[/swf]\n'}
        else{oEditor.InsertHtml('<object codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="400" height="300"><param name="movie" value="'+path+'" /><param name="quality" value="high" /><param name="AllowScriptAccess" value="never" /><embed src="'+path+'" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="400" height="300" /></object>')}
 	  	break;
 	  default :
        if (EditType=="UBBEditor"){
        if (memberDown==1)
	         {parent.document.forms[0].Message.value+='[mDown='+path+']点击下载此文件[/mDown]\n'}
         else
	         {parent.document.forms[0].Message.value+='[down='+path+']点击下载此文件[/down]\n'}
        }
        else{oEditor.InsertHtml('<a href="'+path+'"><img border="0" src="'+Fhref+'images/download.gif" alt="" style="margin:0px 2px -4px 0px"/>点击下载此文件</a>')}
        break;
     }
}
//写入顶部Flash文件
function WriteHeadFlash(Path,Width,Height,Transparent){
	 var Temp,T=""
	 Temp='<object classid="clsid:D27CDB6E-AE6D-11CF-96B8-444553540000" id="FlashH" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0" border="0" width="'+Width+'" height="'+Height+'">'
	 Temp+='<param name="movie" value="'+Path+'"/>'
	 Temp+='<param name="quality" value="High"/>'
	 Temp+='<param name="scale" value="ExactFit"/>'
	 if (Transparent) {Temp+=' <param name="wmode" value="transparent"/>';T='wmode="transparent"'}
	 Temp+='<embed src="'+Path+'" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" name="FlashH" width="'+Width+'" height="'+Height+'" quality="High"'+T+' scale="ExactFit"/>'
	 Temp+='</object>'
	 document.getElementById("FlashHead").innerHTML=Temp
}

//获得引用连接
function getTrackbackURL(id){
	var strHTML = "";
	strHTML = '<span id="tbSpan">请输入验证码 <input id="vCode" maxLength="4" size="4" style="border:1px solid #999;"/> <img id="tbCode" src="about:blank" onerror="src=\'common/getCode.asp?s='+Math.random()+'\'" onclick="src=\'common/getCode.asp?s='+Math.random()+'\'" style="margin-bottom:-4px;height:20px;width:40px;cursor:pointer" title="看不清楚？点击刷新验证码！" alt="加载中..."/> <input type="button" value="获取" onclick="getTB('+id+')"/></span><input id="getTBURL" style="border:1px solid #999;width:100%;display:none">';
	showPopup("获取引用地址",strHTML,250,200);
}

function getTB(id){
	if (document.getElementById("vCode").value.length <4){
		alert("请输入验证码");
		document.getElementById("vCode").select();
		return;
	}
	window._tBID = id;
	var tJS = document.getElementById("tbJS");
	if (!tJS){
		tJS = document.createElement("script");
		tJS.id = "tbJS";
		document.getElementsByTagName("HEAD")[0].appendChild(tJS);
	}
	
	tJS.src = "getValidateKey.asp?tbID=" + id + "&type=trackback&vcode=" + document.getElementById("vCode").value;
}

function setTBKey(code,baseurl){
	if (!code || code == "codeError"){
		alert("验证码错误");
		document.getElementById("vCode").select();
		document.getElementById("tbCode").src = 'common/getCode.asp?s='+Math.random();
		return;
	}
	var tURL = document.getElementById("getTBURL");
	var pBody = document.getElementById("popBody");
	pBody.style.width = "400px";
	document.getElementById("tbSpan").style.display = "none";
	tURL.style.display = "";
//	tURL.value = /(.+\/)/i.exec(location.href)[0] + "trackback.asp?tbID=" + window._tBID + "&action=addtb&tbKey=" + code;
	tURL.value = baseurl + "trackback.asp?tbID=" + window._tBID + "&action=addtb&tbKey=" + code;
}

//popup support
function showMask(){
	var mask = document.getElementById("webMask");
	if (!mask){
		mask = document.createElement("div");
		mask.id = "webMask";
		mask.style.cssText = "position:absolute;width:100%;left:0px;top:0px;background:#000;filter:Alpha(opacity=50);-moz-opacity:0.5";
		document.body.appendChild(mask);
	}
	var h = document.documentElement.scrollHeight;
	mask.style.display = "";
	mask.style.height = h + "px";	
}

function hideMask(){
	var mask = document.getElementById("webMask");
	if (mask) mask.style.display = "none";
	
	var vImg = document.getElementById("vcodeImg");
	if (vImg) vImg.src="common/getCode.asp?s="+Math.random();
}

function showPopup(title,html,width){
	showMask();
	displaySelect(false);
	var pContent = document.getElementById("popContent");
	if (!pContent){
		pContent = document.createElement("div");
		pContent.id = "popContent";
		pContent.style.cssText = "position:absolute;width:100%;left:0px;top:0px;text-align:center";
		document.body.appendChild(pContent);
	}
	
	var pBody = document.getElementById("popBody");
	if (!pBody){
		pBody = document.createElement("div");
		pBody.id = "popBody";
		pBody.style.cssText = "background:#fff;margin:auto;padding:3px;text-align:left;-moz-border-radius:5px;";
		pContent.appendChild(pBody);
	}
	pBody.style.width = width + "px";
	var closeButton = isIE()?'<font style="float:right;font-family:webdings;cursor:pointer;margin-top:-3px" onclick="hidePopup()">r</font>':'<font style="float:right;cursor:pointer;margin-top:-2px" onclick="hidePopup()"><u>close</u></font>';
	var strHTML = '<h4 style="color:#000;font-size:14px;margin:4px;margin-bottom:2px">'+ closeButton + (title?title:'无标题窗口') + '</h4>';
	strHTML += '<div style="background:#e5e5e5;margin:4px;padding:4px;color:#333">'+html+'</div>'
	pBody.innerHTML = strHTML;
	
	var height = pContent.offsetHeight;
	var bodyHeight = isIE()?document.documentElement.offsetHeight:document.documentElement.clientHeight;
	pContent.style.display = "";
	pContent.style.top = document.documentElement.scrollTop + ((bodyHeight - height)/2)+ "px";
}

function hidePopup(){
	hideMask();
	displaySelect(true);
	var pContent = document.getElementById("popContent");
	if (pContent) pContent.style.display = "none";
}

function displaySelect(status){
	var s = document.getElementsByTagName("select");
	for (var i=0;i<s.length;i++){
		s[i].style.display = (status)?"":"none";
	}
}

//填充侧边栏内容
function ﻿callSideBar(html){
	if (window._sidebarReady) {
		fillSidebar(html);
	}else{
		window._sidebarCache = html;
	}
}

function initSidebar(){
	window._sidebarReady = true;
	if (window._sidebarCache) {
		fillSidebar(window._sidebarCache);
	}
}

function fillSidebar(html){
	var sd = $("sidebarDynamic");
	fillHTML(sd,html);
	window._sidebarCache = null;
}

//初始化登录状态的表现 ，for static mode
// evio 优化于 09-09-10
function initLogin(CookieName){
	var n = getCookie(CookieName);
	if (n) {
		//用户登录
		var u = /memName=(\w+)/.exec(n);
		var ucn = /memName=([^\u4e00-\u9fa5]*)/.exec(n);
		var menvalidate = /DisValidate=(\w+)/.exec(n);
		var IsAdmin = /IsAdmin=(\w+)/.exec(n);
		var cnvalue = decodeURI(ucn[1]).split("&")[0];
		if (u){
				var un = document.forms["frm"]["username"];
				un.value = u[1];
				un.readOnly = true;
				if ($("passArea")) $("passArea").parentNode.removeChild($("passArea"));
				if ($("EmailArea")) $("EmailArea").parentNode.removeChild($("EmailArea"));
				if ($("WebSiteArea")) $("WebSiteArea").parentNode.removeChild($("WebSiteArea"));
				if ($("GuestCanRemeberComment")) $("GuestCanRemeberComment").parentNode.removeChild($("GuestCanRemeberComment"));
				if ($("removeCommTips")) $("removeCommTips").parentNode.removeChild($("removeCommTips"));
				if (IsAdmin[1] == "True" || IsAdmin[1] == "true" || menvalidate[1] == "False" || menvalidate[1] == "false") $("removevalidate").parentNode.removeChild($("removevalidate"));
		}else if(cnvalue.length > 0){
				var cnun = document.forms["frm"]["username"];
				cnun.value = cnvalue;
				cnun.readOnly = true;
				if ($("passArea")) $("passArea").parentNode.removeChild($("passArea"));
				if ($("EmailArea")) $("EmailArea").parentNode.removeChild($("EmailArea"));
				if ($("WebSiteArea")) $("WebSiteArea").parentNode.removeChild($("WebSiteArea"));
				if ($("GuestCanRemeberComment")) $("GuestCanRemeberComment").parentNode.removeChild($("GuestCanRemeberComment"));
				if ($("removeCommTips")) $("removeCommTips").parentNode.removeChild($("removeCommTips"));
				if (IsAdmin[1] == "True" || IsAdmin[1] == "true" || menvalidate[1] == "False" || menvalidate[1] == "false") $("removevalidate").parentNode.removeChild($("removevalidate"));
		}else{
			//var escapeStr = escape("|$|")
			var Guest = /Guest=(.*)/.exec(unescape(decodeURI(n)));
			if (Guest != null && Guest[1].json() != null){
			var ComRe = Guest[1].json();
			if (ComRe.record){
				try{
					if (document.forms[0].username) document.forms[0].username.value = ComRe.username;
					if (document.forms[0].Email) document.forms[0].Email.value = ComRe.useremail;
					if (document.forms[0].WebSite) document.forms[0].WebSite.value = ComRe.userwebsite;
					}catch(e){if (e.description.length > 0) alert(e.description);}
				}
			}
		}
		
		//blog目前的权限
		var m =  /memRight=(\d+)/.exec(n);
		if (m) {
				var rn = parseInt(m[1],2);
				
				var ss = document.styleSheets[0];
				var rule = ss.rules || ss.cssRules;
				
				if (rn&(1<<2) && rn&(1<<4)) rule[0].style.display = "";
				if (rn&(1<<8)) {rule[1].style.display = "";}
		}
	}
}
function delCommentConfirm(){
	if (!window.confirm('是否删除该评论?')) {return false}
	return true;
}

//获取cookie
function getCookie(name){
		var r = new RegExp("(?:^|;+|\\s+)" + name + "=([^;]*?)(?:;|$)");
		var m = document.cookie.match(r);
		return (!m ? "" : m[1]);
}

//计数器
function ping(){
	setTimeout(toPing,500);
}

//开始统计
function toPing(){
	var pingBlog = document.createElement("script");
	pingBlog.chatset = "utf-8";
	pingBlog.src = "static_js_ping.asp?id=" + g_logID;
	
	document.getElementsByTagName("HEAD")[0].appendChild(pingBlog);
}

//ping的回调
function callPing(num){
	$("countNum").innerHTML = num;
}

//填充html
var fillHTML = function (el,HTMLString) {
    if (!el) return;
    if (window.ActiveXObject) { //For IE
        el.innerHTML = "<img style='display:none'/>" + HTMLString.replace(/<script([^>]*)>/ig, '<script$1 defer>');
        el.removeChild(el.firstChild)
    } else { //For Mozilla,Opare
        var nSibling = el.nextSibling;
        var pNode = el.parentNode;
        pNode.removeChild(el);
        el.innerHTML = HTMLString;
        pNode.insertBefore(el,nSibling)
    }
}

//复制内容到剪贴板
var lang = new Array();
var userAgent = navigator.userAgent.toLowerCase();
var is_opera = userAgent.indexOf('opera') != -1 && opera.version();
var is_moz = (navigator.product == 'Gecko') && userAgent.substr(userAgent.indexOf('firefox') + 8, 3);
var is_ie = (userAgent.indexOf('msie') != -1 && !is_opera) && userAgent.substr(userAgent.indexOf('msie') + 5, 3);

function copycode(obj) {
    if(is_ie && obj.style.display != 'none') {
        var rng = document.body.createTextRange();
        rng.moveToElementText(obj);
        rng.scrollIntoView();
        rng.select();
        rng.execCommand("Copy");
        rng.collapse(false);
		alert("代码已经复制到剪切板");
    }
}

/*
 * 打开连接特效
 */
function openLinkEffect(o){
	o.innerHTML = '<img src="images/Loading.gif" border="0" style="position:absolute"/>&nbsp;&nbsp;&nbsp;&nbsp;'
}

/*=============给评论翻页===============*/
/*
 * 打开评论页面
 */
function openCommentPage(o){
	setTimeout(function(){loadComment(o.getAttribute("page"));},0);
	o.innerHTML = '<img src="images/Loading.gif" border="0" style="position:absolute"/>&nbsp;&nbsp;&nbsp;&nbsp;';
	o.style.textDecoration = "none"
}

/*
 * 加载评论数据
 */
function loadComment(page,needTips){
	if (window._loadComment) {
		return;
	}
	
	if (needTips) {
		fillComment("<div style='margin-bottom:10px;'>正在加载评论数据...</div>");
	}
	window._loadComment = true;
	var cJS = document.createElement("script");
	cJS.chatset = "utf-8";


	cJS.src = "load_Comment.asp?id=" + g_logID + "&page=" + page + "&	comDesc=" + g_comDesc + "&TimeStamp="+new Date().getTime();
	
	document.getElementsByTagName("HEAD")[0].appendChild(cJS);
}

/*
 * 尝试从hash里加载评论
 */
function tryLoadComment(){
	var hash = location.hash;
	var page = /page=(\d)+/g.exec(hash);
	if (page && page[1]>1) {
		loadComment(page[1],true);
	}
}

/*
 * 填充评论
 */
function fillComment(html){
	var cb = $("commentBox");
	cb.innerHTML = html;
	window._loadComment = false;
}

/**
 * 主人回复
 */
function replyMsg(logId,id,a1,a2,a3){
	var _r = $("reply_" + id);
	if (!_r) {
		_r = document.createElement("div");
		_r.id = "reply_" + id;
		var _c = $("commcontent_" + id);
		_c.appendChild(_r);

		_r.innerHTML = '<br/><div class="replyPanel"><div class="commenttop replyTitle"><img alt="评论回复" style="margin: 0px 2px -3px 0px;" src="images/icon_reply.gif"/> 评论回复</div><div class="commentcontent replyContent">' +
				'<form onsubmit="return checkReplyMsg(this)" method="post" action="reply.asp" target="replyFrame_'+id+'">' +
				'<input type="hidden" name="id" value="'+id+'"/><input type="hidden" name="logId" value="'+logId+'"/>' +
				'<input type="hidden" name="a1" value="'+a1+'"/><input type="hidden" name="a2" value="'+a2+'"/><input type="hidden" name="a3" value="'+a3+'"/>' +
				'<textarea name="reply" style="width: 99%; height: 60px;" class="editTextarea" id="edit_'+id+'"></textarea>' +
				'<input type="submit" value="回复" class="userbutton"  id="button_'+id+'"/> <input onclick="removeReplyMsg('+id+')" type="button" value="取消" class="userbutton"/>' +
				'<iframe name="replyFrame_'+id+'" style="display:none"/></form></div></div>';
	}
	$('button_'+id).focus();
	$('edit_'+id).select();
}

function checkReplyMsg(o){
	var msg = Trim(o.reply.value)
	if (msg == "") {
		alert("回复不能为空")
		o.reply.select();
		return false
	}
	return true
}

function removeReplyMsg(id){
	var _r = $("reply_" + id);
	if (_r) {
		_r.parentNode.removeChild(_r);
	}
}
function istrong(){
		var n = "";
		CheckPassword($("cpassword").value);
		
		function CheckPassword(val){
			var z = val;
			var regexp = new RegExp("[0-9]");
				if (regexp.test(val)){
					n += ("1|$|");
				}
			regexp = new RegExp("[a-z]");
				if (regexp.test(val)){
					n += ("1|$|");
				}
			regexp = new RegExp("[A-Z]");
				if (regexp.test(val)){
					n += ("1|$|");
				}
			regexp = new RegExp("[^a-zA-Z0-9]");
				if (regexp.test(val)){
					n += ("1|$|");
				}
			if (val.length > 12){
					n += ("1|$|");
				}
			n += "end";
			var c = (n.split("|$|").length) - 1 ;
			$("strong").src = "images/" + c + ".gif";
		}
}

function AddNewCate(){
	var e = "";
	e += "<table width='100%'>";
	e += "<tr><td align='center' width='100%'>";
	e += "<div style='text-align:center;width:100%;'>新分类名:&nbsp;<input type='text' value='' id='log_NewCate' /><br />新静态文件目录名:&nbsp;<input type=\"text\" value=\"\" id=\"log_NewPart\" onblur=\"ReplaceInput(this,window.event);\" onkeyup=\"ReplaceInput(this,window.event)\"> <a href='javascript:void(0)' onclick='GoToCateAdd()'>确定</a></div>";
	e += "</td></tr>";
	e += "</table>";
	return e;
}

function ModiyPassProtect(Name, width, Question, ID){
	showPopup((Name + "修改密码保护验证"), "<div id='passContent'>" + ModiyStr(Question, Name, 0, ID) + "</div>", width);
}

function ModiyStr(Question, Name, i, ID){
	var e = "";
	e += "<table width='100%'>";
	e += "<tr><td align='right' width='30%'>密保问题:</td>";
	e += "<td align='left'>" + Question + "</td></tr>";
	e += "<tr><td align='right'>密保答案:</td><td align='left'><input type='text' value='' id='c_Answer' class='userpass'></td></tr>";
	e += "<tr><td colspan='2' align='center'><input type='button' value='点击验证密码保护' style='width:70%' onclick=\"GoToPassCheck('"+ Name +"', " + i + ");\"></td></tr>";
	e += "</table>";
	if (Question.length > 0){
		return e;
	}else{
		if (i == 0){
			return "<a href='javascript:void(0)' onclick='GetNoPassInforMation(" + ID + ")'>您没有申请密码保护,点击这里设置密码保护.</a>";
		}else{
			return "该用户没有设置密码保护,系统将停止找回密码功能";	
		}
	}
}

function ModiyStr2(id){
	var e = "";
	e += "<table width='100%'>";
	e += "<tr><td align='right' width='30%'>新密保问题:</td>";
	e += "<td align='left'><input type='text' value='' id='c_Question' class='userpass' /></td></tr>";
	e += "<tr><td align='right'>新密保答案:</td><td align='left'><input type='text' value='' id='c_Answer' class='userpass' /></td></tr>";
	e += "<tr><td colspan='2' align='center'><input type='button' value='更新密码保护' style='width:70%' onclick=GoToPassCheck2("+id+");></td></tr>";
	e += "</table>";
	return e;
}

function PasswordProtection(){
	var e = "";
	e += "<table width='100%'>";
	e += "<tr><td align='right' width='30%'>用户名:</td>";
	e += "<td align='left'><input type='text' value='' id='c_Name' class='userpass' /></td></tr>";
	e += "<tr><td colspan='2' align='center'><input type='button' value='确定用户名' onclick=\"PostPName();\"></td></tr>";
	e += "</table>";
	showPopup("找回密码", "<div id='passContent'>" + e + "</div>", 400);
}

function ModiyStr3(id){
	var e = "";
	e += "<table width='100%'>";
	e += "<tr><td align='right' width='30%'>新密码:</td>";
	e += "<td align='left'><input type='text' value='' id='c_Password' class='userpass' /></td></tr>";
	e += "<tr><td align='right'>确认密码:</td><td align='left'><input type='text' value='' id='c_RePassword' class='userpass' /></td></tr>";
	e += "<tr><td colspan='2' align='center'><input type='button' value='更新密码' onclick=\"Gotoupdatepass("+id+")\"></td></tr>";
	e += "</table>";
	return e;
}
function InfoCss(nStr){
	var LoadInfo = document.createElement("div");
	LoadInfo.id = "LoadInfo";
	document.body.appendChild(LoadInfo);
	var LoadInformation = document.createElement("span");
	LoadInformation.id = "LoadInformation";
	LoadInformation.style.cssText = "font-size:11px; font-family:Arial, Helvetica, sans-serif; color:#FF6c00";
	var loader = document.createElement("img");
	loader.src = "images/loader.gif";
	LoadInfo.appendChild(LoadInformation);
	LoadInfo.appendChild(loader);
	LoadInfo.style.cssText="position:fixed;width:240px;height:40px;border:1px solid #98C3F5;background-color:#E3F8F9;padding:10px;text-align:center;top:400px;margin-left:-125px;left:50%;*position:absolute;*top:expression(offsetParent.scrollTop + 220 + 'px');filter:Alpha(Opacity=60);opacity:0.6;ght:bold;";
	LoadInformation.innerHTML=nStr;
}
function LoadInformation(nStr){
	if (nStr!=null){
		if (!$("LoadInfo")) {InfoCss(nStr);}
	}else{
		if ($("LoadInfo")) {document.body.removeChild($("LoadInfo"));}
	}
}

function get_checkcode() {
	document.getElementById("checkcode").innerHTML = '<img  id="checkcodeimg" src="common/getcode.asp?t='+Math.random()+'" alt="点击刷新验证码" style="cursor:pointer;border:0;vertical-align:middle;height:18px;" onclick="this.src=\'common/getcode.asp?t=\'+Math.random()" />'
}

function getAlias(){
	var ccate;
	var cname = document.forms['frm'].cname.value;
	var ctype = document.forms['frm'].ctype.options[document.forms['frm'].ctype.options.selectedIndex].value;
	var first = document.forms['frm'].FirstPost.value;
	if (first == 1){ccate = document.forms['frm'].log_CateID.options[document.forms['frm'].log_CateID.options.selectedIndex].value;}else{ccate = $('log_CateID').value;}
	CheckAlias(cname, ctype, ccate);
}


//创建文件夹规则 example:
//<input onblur="ReplaceInput(this,window.event)" onkeyup="ReplaceInput(this,window.event)" />
function ReplaceInput(obj, cevent){
	var str = ["<", ">", "/", "\\", ":", "*", "?", "|", "\"", /[\u4E00-\u9FA5]/g];
	if(cevent.keyCode != 37 && cevent.keyCode != 39){
		//obj.value = obj.value.replace(/[\u4E00-\u9FA5]/g,'');
		for (var i = 0 ; i < str.length ; i++){
			obj.value = obj.value.replace(str[i], "");
		}
	}
}