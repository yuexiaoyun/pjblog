﻿<%
'==================================
'  日志编辑类
'    更新时间: 2006-1-22
'==================================
Class logArticle
    Private weblog, Pingweb
    Public categoryID, logTitle, logAuthor, logEditType
    Public logIsShow, logIsDraft, logWeather, logLevel, logCommentOrder, logReadpw, logPwtips, logPwtitle, logPwcomm
    Public logDisableComment, logIsTop, logFrom, logFromURL, isajax, logdescriptionFilt
    Public logDisableImage, logDisableSmile, logDisableURL, logDisableKeyWord, logMeta, logKeyWords, logDescription, TagMeta
    Public logQuote, logMessage, logIntro, logIntroCustom, logTags, logPublishTimeType, logPubTime, logTrackback, logCommentCount, logQuoteCount, logViewCount, logCname, logCtype
    Private logUbbFlags, PubTime, sqlString

    Private Sub Class_Initialize()
        Set weblog = Server.CreateObject("ADODB.RecordSet")
        categoryID = 0
        logTitle = ""
        logEditType = 1
        logIntroCustom = 0
        logIntro = ""
        logAuthor = "null"
        logWeather = "sunny"
        logLevel = "level3"
        logCommentOrder = 1
        logDisableComment = 0
        logIsShow = True
        logIsTop = False
        logIsDraft = False
        logFrom = "本站原创"
        logFromURL = siteURL
        logDisableImage = 0
        logDisableSmile = 0
        logDisableURL = 0
        logDisableKeyWord = 0
        logCommentCount = 0
        logQuoteCount = 0
        logViewCount = 0
        logMessage = ""
        logTrackback = ""
        logTags = ""
        logPubTime = "2006-1-1 00:00:00"
        logPublishTimeType = "now"
        logCname = ""
        logCtype = "htm"
        logReadpw = ""
        logPwtips = ""
        logPwtitle = False
        logPwcomm = False
        logmeta = 0
        logKeyWords = ""
        logDescription = ""
        isajax = false
    End Sub

    Private Sub Class_Terminate()
        Set weblog = Nothing
    End Sub

    '*********************************************
    '发表新日志
    '*********************************************

    Public Function postLog()
        postLog = Array( -4, "准备发表日志!", -1)
        weblog.Open "blog_Content", Conn, 1, 2
        SQLQueryNums = SQLQueryNums + 1

        If stat_AddAll<>True And stat_Add<>True Then
            postLog = Array( -3, "您没有权限发表日志!", -1)
            Exit Function
        End If
		TagMeta = logTags
        '-------------------处理Tags--------------------
        Dim tempTags,tempTags2, loadTagString, loadTags, loadTag, getTags
        tempTags = Split(CheckStr(logTags), ",")

        Set getTags = New Tag

        Dim post_tag,post_tag2, post_taglist
        post_taglist = ""

        '添加新的Tag
        For Each post_tag in tempTags
      	  	tempTags2 = Split(post_tag," ")
      	  	If UBound(tempTags2)>0 Then
	      	  	For Each post_tag2 in tempTags2
		            If Len(Trim(post_tag2))>0 Then
		                post_taglist = post_taglist & "{" & getTags.insert(CheckStr(Trim(post_tag2))) & "}"
		            End If
	      	  	Next
      	  	Else
	      	  	If Len(Trim(post_tag))>0 Then
		            post_taglist = post_taglist & "{" & getTags.insert(CheckStr(Trim(post_tag))) & "}"
	      	  	End If
      	  	End If
        Next
        logTags = post_taglist
        Call Tags(2)
        Set getTags = Nothing
        '--------------处理日期---------------------
        If CheckStr(logPublishTimeType) = "now" Then
            PubTime = DateToStr(Now(), "Y-m-d H:I:S")
        Else
            PubTime = DateToStr(CheckStr(logPubTime), "Y-m-d H:I:S")
        End If

        '---------------分割日志--------------------
        If logIntroCustom = 1 Then
            If Int(logEditType) = 1 Then
                logIntro = closeUBB(CheckStr(HTMLEncode(logIntro)))
            Else
                logIntro = closeHTML(CheckStr(logIntro))
            End If
        Else
            If Int(logEditType) = 1 Then
                If blog_SplitType Then
                    logIntro = closeUBB(CheckStr(SplitLines(HTMLEncode(logMessage), blog_introLine)))
                Else
                    logIntro = closeUBB(CheckStr(CutStr(HTMLEncode(logMessage), blog_introChar)))
                End If
            Else
                logIntro = closeHTML(CheckStr(SplitLines(logMessage, blog_introLine)))
            End If
        End If

        '日志基本状态
        logIsShow = CBool(logIsShow)
        logCommentOrder = CBool(logCommentOrder)
        logDisableComment = CBool(logDisableComment)
        logIsTop = CBool(logIsTop)
        logIsDraft = CBool(logIsDraft)
        logPwtitle = CBool(logPwtitle)
        logPwcomm = CBool(logPwcomm)
        logMeta = CBool(logMeta)

        'UBB 特别属性
        If logDisableSmile = 1 Then logDisableSmile = 1 Else logDisableSmile = 0
        If logDisableImage = 1 Then logDisableImage = 1 Else logDisableImage = 0
        If logDisableURL = 1 Then logDisableURL = 0 Else logDisableURL = 1
        If logDisableKeyWord = 1 Then logDisableKeyWord = 0 Else logDisableKeyWord = 1
        If logIntroCustom = 1 Then logIntroCustom = 0 Else logIntroCustom = 1
        logUbbFlags = logDisableSmile & "0" & logDisableImage & logDisableURL & logDisableKeyWord & logIntroCustom

		'Meta特别属性
		If logMeta <> true Then
			logDescription = left(FilterUBBTags(FilterHtmlTags(logdescriptionFilt)),254)
		Else
			logDescription = FilterUBBTags(FilterHtmlTags(logDescription))
		End If
		
		If logMeta <> true Then
			logKeyWords = CheckStr(TagMeta)
			If isblank(logKeyWords) Then
				logKeyWords = CheckStr(logTitle)
			Else
				logKeyWords = Replace(Replace(Replace(logKeyWords, ",", "|"), " ", "|"), "|", ",")
			End If
		End If

        weblog.addNew
        If IsBlank(logCname) Then
            logCname = weblog("log_ID")
        End If
        weblog("log_CateID") = CheckStr(categoryID)
        weblog("log_Author") = CheckStr(logAuthor)
        weblog("log_Title") = CheckStr(logTitle)
        weblog("log_weather") = CheckStr(logWeather)
        weblog("log_Level") = CheckStr(logLevel)
        weblog("log_From") = CheckStr(logFrom)
        weblog("log_FromURL") = CheckStr(logFromURL)
        weblog("log_Content") = CheckStr(logMessage)
        weblog("log_Intro") = logIntro
        weblog("log_Tag") = logTags
        weblog("log_UbbFlags") = logUbbFlags
        weblog("log_IsShow") = logIsShow
        weblog("log_IsTop") = logIsTop
        weblog("log_PostTime") = PubTime
        weblog("log_IsDraft") = logIsDraft
        weblog("log_DisComment") = logDisableComment
        weblog("log_EditType") = logEditType
        weblog("log_ComOrder") = logCommentOrder
		Dim pingCname
		If conn.Execute("select count(log_ID) from blog_Content where log_Cname='"&logCname&"'")(0) > 0 Then
    	    pingCname = Left(logCname, 36) & Year(now) & lenNum(Month(now)) & lenNum(Day(now)) & lenNum(Hour(now)) & lenNum(Minute(now)) & lenNum(Second(now))
		Else
	        pingCname = logCname
		End If
		weblog("log_Cname") = pingCname
        weblog("log_Ctype") = logCtype
        weblog("log_Readpw") = logReadpw
        weblog("log_Pwtips") = logPwtips
        weblog("log_Pwtitle") = logPwtitle
        weblog("log_Pwcomm") = logPwcomm
        weblog("log_Meta") = logMeta
        weblog("log_KeyWords") = logKeyWords
        weblog("log_Description") = logDescription
        
        SQLQueryNums = SQLQueryNums + 2
        weblog.update
        weblog.Close


        '------------------统计日志-----------------------------
        Dim PostLogID
        PostLogID = Conn.Execute("SELECT TOP 1 log_ID FROM blog_Content ORDER BY log_ID DESC")(0)
		if isajax <> true then
        	Conn.Execute("UPDATE blog_Member SET mem_PostLogs=mem_PostLogs+1 WHERE mem_Name='"&logAuthor&"'")
		end if
        If Not logIsDraft Then
			if isajax <> true then
            	Conn.Execute("UPDATE blog_Info SET blog_LogNums=blog_LogNums+1")
            	Conn.Execute("UPDATE blog_Category SET cate_count=cate_count+1 where cate_ID="&categoryID)
            	SQLQueryNums = SQLQueryNums + 2
			end if
        End If


        '-------------------输出静态日志档案--------------------
        Dim preLog, nextLog
        '输出日志到文件
		If isajax = false then
        	PostArticle PostLogID, False
		End if
        '输出附近的日志到文件
        Set preLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime<#"&PubTime&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime DESC")
        Set nextLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime>#"&PubTime&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime ASC")
        if isajax = false then
			If Not preLog.EOF Then PostArticle preLog("log_ID"), False
        	If Not nextLog.EOF Then PostArticle nextLog("log_ID"), False
		end if

        Call updateCache

        Session(CookieName&"_LastDo") = "AddArticle"
        session(CookieName&"_draft_"&logAuthor) = conn.Execute("select count(log_ID) from blog_Content where log_Author='"&logAuthor&"' and log_IsDraft=true")(0)
        SQLQueryNums = SQLQueryNums + 1



        If logIsDraft Then
            postLog = Array(1, "日志成功保存为草稿!", PostLogID)
        Else
            postLog = Array(0, "恭喜!日志发表成功!", PostLogID)
			If blog_IsPing Then
				Set Pingweb = New ping
					Dim PiUrl
					If blog_postFile = 2 Then
						PiUrl = CreateUrl(Conn.Execute("Select cate_Part From blog_Category Where cate_ID=" & categoryID)(0), pingCname, logCtype)
					Else
						PiUrl = "default.asp?id=" & PostLogID
					End If
					Call Pingweb.WebPing(PiUrl)
					postLog = Array(0, "恭喜!日志发表成功!<br />发送PING服务成功!", PostLogID)
				Set Pingweb = Nothing
			End If
        End If

        '-------------------引用通告-------------------
        If logTrackback<>Empty And logIsShow = True And logIsDraft = False Then
            Dim log_QuoteEvery, log_QuoteArr, logid, LastID
            Set LastID = Conn.Execute("SELECT TOP 1 log_ID FROM blog_Content ORDER BY log_ID DESC")
            logid = LastID("log_ID")
            log_QuoteArr = Split(logTrackback, ",")
            For Each log_QuoteEvery In log_QuoteArr
                Trackback Trim(log_QuoteEvery), siteURL&"default.asp?id="&logid, logTitle, CutStr(CheckStr(logIntro), 252), siteName
                Set LastID = Nothing
            Next
        End If
    End Function

    '*********************************************
    '编辑日志
    '*********************************************

    Public Function editLog(id)
        editLog = Array( -4, "准备编辑日志!", -1)
        If IsEmpty(id) Then
            getLog = Array( -5, "ID号不能为空!")
            Exit Function
        End If
        If Not IsInteger(id) Then
            editLog = Array( -1, "非法ID号!", -1)
            Exit Function
        End If

        sqlString = "SELECT top 1 * FROM blog_Content WHERE log_ID="&id&""
        weblog.Open sqlString, Conn, 1, 3
        SQLQueryNums = SQLQueryNums + 1

        If weblog.EOF Or weblog.bof Then
            editLog = Array( -2, "无法找到相应文章!", -1)
            Exit Function
        End If

        If stat_EditAll<>True And (stat_Edit And weblog("log_Author") = logAuthor)<>True Then
            editLog = Array( -3, "您没有权限编辑日志!", -1)
            Exit Function
        End If

        logAuthor = weblog("log_Author")
        	Conn.Execute("UPDATE blog_Category SET cate_count=cate_count-1 where cate_ID="&weblog("log_CateID"))
        	Conn.Execute("UPDATE blog_Category SET cate_count=cate_count+1 where cate_ID="&CheckStr(categoryID))
		TagMeta = logTags
        '-------------------处理Tags--------------------
        Dim tempTags,tempTags2, loadTagString, loadTags, loadTag, getTags
        tempTags = Split(CheckStr(logTags), ",")
        loadTagString = weblog("log_Tag")

        Set getTags = New Tag

        '清除旧的Tag
        If Len(loadTagString)>0 Then
            loadTagString = Replace(loadTagString, "}{", ",")
            loadTagString = Replace(loadTagString, "}", "")
            loadTagString = Replace(loadTagString, "{", "")
            loadTags = Split(loadTagString, ",")

            For Each loadTag in loadTags
                getTags.Remove loadTag
            Next
        End If

        Dim post_tag,post_tag2, post_taglist
        post_taglist = ""

        '添加新的Tag
        For Each post_tag in tempTags
      	  	tempTags2 = Split(post_tag," ")
      	  	If UBound(tempTags2)>0 Then
	      	  	For Each post_tag2 in tempTags2
		            If Len(Trim(post_tag2))>0 Then
		                post_taglist = post_taglist & "{" & getTags.insert(CheckStr(Trim(post_tag2))) & "}"
		            End If
	      	  	Next
      	  	Else
	      	  	If Len(Trim(post_tag))>0 Then
		            post_taglist = post_taglist & "{" & getTags.insert(CheckStr(Trim(post_tag))) & "}"
	      	  	End If
      	  	End If
        Next
        logTags = post_taglist
        Call Tags(2)
        Set getTags = Nothing
        '--------------处理日期---------------------
        If CheckStr(logPublishTimeType) = "now" Then
            PubTime = DateToStr(Now(), "Y-m-d H:I:S")
        Else
            PubTime = DateToStr(CheckStr(logPubTime), "Y-m-d H:I:S")
        End If

        '---------------分割日志--------------------
        If logIntroCustom = 1 Then
            If Int(logEditType) = 1 Then
                logIntro = closeUBB(CheckStr(HTMLEncode(logIntro)))
            Else
                logIntro = closeHTML(CheckStr(logIntro))
            End If
        Else
            If Int(logEditType) = 1 Then
                If blog_SplitType Then
                    logIntro = closeUBB(CheckStr(SplitLines(HTMLEncode(logMessage), blog_introLine)))
                Else
                    logIntro = closeUBB(CheckStr(CutStr(HTMLEncode(logMessage), blog_introChar)))
                End If
            Else
                logIntro = closeHTML(CheckStr(SplitLines(logMessage, blog_introLine)))
            End If
        End If

        '日志基本状态
        logIsShow = CBool(logIsShow)
        logCommentOrder = CBool(logCommentOrder)
        logDisableComment = CBool(logDisableComment)
        logIsTop = CBool(logIsTop)
        logIsDraft = CBool(logIsDraft)
        logPwtitle = CBool(logPwtitle)
        logPwcomm = CBool(logPwcomm)
        logMeta = CBool(logMeta)

        'UBB 特别属性
        If logDisableSmile = 1 Then logDisableSmile = 1 Else logDisableSmile = 0
        If logDisableImage = 1 Then logDisableImage = 1 Else logDisableImage = 0
        If logDisableURL = 1 Then logDisableURL = 0 Else logDisableURL = 1
        If logDisableKeyWord = 1 Then logDisableKeyWord = 0 Else logDisableKeyWord = 1
        If logIntroCustom = 1 Then logIntroCustom = 0 Else logIntroCustom = 1
        logUbbFlags = logDisableSmile & "0" & logDisableImage & logDisableURL & logDisableKeyWord & logIntroCustom

        If logIsDraft = False Then weblog("log_Modify") = "[本日志由 "&memName&" 于 "&DateToStr(Now(), "Y-m-d H:I A")&" 更新]"
        If logIsDraft = False And weblog("log_IsDraft")<>logIsDraft Then
			if isajax <> true then
            	Conn.Execute("UPDATE blog_Info SET blog_LogNums=blog_LogNums+1")
            	Conn.Execute("UPDATE blog_Category SET cate_count=cate_count+1 where cate_ID=" & CheckStr(categoryID))
			end if
            SQLQueryNums = SQLQueryNums + 2
        End If

		'Meta特别属性
		If logMeta <> true Then
			logDescription = left(FilterUBBTags(FilterHtmlTags(logdescriptionFilt)),254)
		Else
			logDescription = FilterHtmlTags(logDescription)
		End If
		
		If logMeta <> true Then
			logKeyWords = CheckStr(TagMeta)
			If isblank(logKeyWords) Then
				logKeyWords = CheckStr(logTitle)
			Else
				logKeyWords = Replace(Replace(Replace(logKeyWords, ",", "|"), " ", "|"), "|", ",")
			End If
		End If

        If IsBlank(logCname) Then
            logCname = weblog("log_ID")
        End If
        weblog("log_Title") = CheckStr(logTitle)
        weblog("log_weather") = CheckStr(logWeather)
        weblog("log_Level") = CheckStr(logLevel)
        weblog("log_From") = CheckStr(logFrom)
        weblog("log_FromURL") = CheckStr(logFromURL)
        weblog("log_Content") = CheckStr(logMessage)
        weblog("log_Intro") = logIntro
        weblog("log_CateID") = CheckStr(categoryID)
        weblog("log_Tag") = logTags
        weblog("log_UbbFlags") = logUbbFlags
        weblog("log_IsShow") = logIsShow
        weblog("log_IsTop") = logIsTop
        weblog("log_PostTime") = PubTime
        weblog("log_IsDraft") = logIsDraft
        weblog("log_DisComment") = logDisableComment
        weblog("log_EditType") = logEditType
        weblog("log_ComOrder") = logCommentOrder
		Dim pingCname
		If conn.Execute("select count(log_ID) from blog_Content where log_id<>"&id&" and log_Cname='"&logCname&"'")(0) > 0 Then
    	    pingCname = left(logCname,36) & Year(now) & lenNum(Month(now)) & lenNum(Day(now)) & lenNum(Hour(now)) & lenNum(Minute(now)) & lenNum(Second(now))
		Else
	        pingCname = logCname
		End If
		weblog("log_Cname") = pingCname
        weblog("log_Ctype")= logCtype
        weblog("log_Readpw") = logReadpw
        weblog("log_Pwtips") = logPwtips
        weblog("log_Pwtitle") = logPwtitle
        weblog("log_Pwcomm") = logPwcomm
        weblog("log_Meta") = logMeta
        weblog("log_KeyWords") = logKeyWords
        weblog("log_Description") = logDescription

        SQLQueryNums = SQLQueryNums + 2
        weblog.update
        weblog.Close

        Dim preLog, nextLog

        '-------------------输出静态日志档案--------------------
        '输出日志到文件
		If blog_postFile = 2 Then
			Dim oldcate, oldctype, oldcname, Dpart, DeHie, DeClassFso
			On Error Resume Next
			'之前如果调用过request.BinaryRead后，不能直接调用request.form了
			'live write 就挂在这里
			oldcname = CheckStr(request.form("oldcname"))
			oldcate = CheckStr(request.form("oldcate"))
			oldctype = CheckStr(request.form("oldtype"))
			If oldcname <> Request.Form("cname") Or oldcate <> Request.Form("log_CateID") Or oldctype <> Request.Form("ctype") Then
				Dpart = Conn.Execute("select cate_Part from blog_Category where cate_ID=" & oldcate)(0)
				DeHie = CreateUrl(Dpart, oldcname, oldctype)
				Set DeClassFso = New cls_FSO
					DeClassFso.DeleteFile(DeHie)
				Set DeClassFso = Nothing
			End If
			'用来检查是否有
			If Err Then Err.Clear
			If isajax = False Then PostArticle id, False
        End If
        '输出附近的日志到文件
        Set preLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime<#"&PubTime&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime DESC")
        Set nextLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE log_PostTime>#"&PubTime&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime ASC")
        If isajax = False Then
			If Not preLog.EOF Then PostArticle preLog("log_ID"), False
        	If Not nextLog.EOF Then PostArticle nextLog("log_ID"), False
		End if
		
        Call updateCache

        Session(CookieName&"_LastDo") = "EditArticle"
        Session(CookieName&"_draft_"&logAuthor) = conn.Execute("select count(log_ID) from blog_Content where log_Author='"&logAuthor&"' and log_IsDraft=true")(0)
        SQLQueryNums = SQLQueryNums + 1

        If logIsDraft Then
            editLog = Array(1, "日志成功保存为草稿!", id)
        Else
            editLog = Array(0, "恭喜!日志编辑成功!", id)
			If blog_IsPing Then
				Set Pingweb = New ping
					Dim PiUrl
					If blog_postFile = 2 Then
						PiUrl = CreateUrl(Conn.Execute("Select cate_Part From blog_Category Where cate_ID=" & categoryID)(0), pingCname, logCtype)
					Else
						PiUrl = "default.asp?id=" & id
					End If
					Call Pingweb.WebPing(PiUrl)
					editLog = Array(0, "恭喜!日志编辑成功!<br />发送PING服务成功!", id)
				Set Pingweb = Nothing
			End If
        End If

        '-------------------引用通告-------------------
        If logTrackback<>Empty And logIsShow = True And logIsDraft = False Then
            Dim log_QuoteEvery, log_QuoteArr
            log_QuoteArr = Split(logTrackback, ",")
            For Each log_QuoteEvery In log_QuoteArr
                Trackback Trim(log_QuoteEvery), siteURL&"default.asp?id="&logid, logTitle, CutStr(CheckStr(logIntro), 252), siteName
            Next
        End If
		If isajax = False Then
			If blog_postFile = 1 Then
				PostHalfStatic id,false
        	End If
		End if
    End Function

    '*********************************************
    '删除日志
    '*********************************************

    Public Function deleteLog(id)
		If blog_postFile =2 Then
	    	Dim pcmpad : pcmpad=Alias(id)
		End If
        deleteLog = Array( -4, "准备删除!")
        If IsEmpty(id) Then
            getLog = Array( -5, "ID号不能为空!")
            Exit Function
        End If

        If Not IsInteger(id) Then
            deleteLog = Array( -1, "非法ID号!")
            Exit Function
        End If

        sqlString = "SELECT top 1 * FROM blog_Content WHERE log_ID="&id&""
        weblog.Open sqlString, Conn, 1, 3
        SQLQueryNums = SQLQueryNums + 1

        If weblog.EOF Or weblog.bof Then
            deleteLog = Array( -2, "找不到相应文章!")
            Exit Function
        End If

        If stat_DelAll<>True And (stat_Del And weblog("log_Author") = logAuthor)<>True Then
            deleteLog = Array( -3, "没有权限删除!")
            Exit Function
        End If

        Dim Pdate, getTag
        Dim tempTags, loadTagString, loadTags, loadTag, getTags, post_Tag
        Pdate = weblog("log_PostTime")
        Conn.Execute("UPDATE blog_Member SET mem_PostLogs=mem_PostLogs-1 WHERE mem_Name='"&weblog("log_Author")&"'")
        If Not weblog("log_IsDraft") Then
            Conn.Execute("UPDATE blog_Category SET cate_count=cate_count-1 where cate_ID="&weblog("log_CateID"))
            Conn.Execute("UPDATE blog_Info SET blog_LogNums=blog_LogNums-1")
            Conn.Execute("update blog_Info set blog_CommNums=blog_CommNums-"&weblog("log_CommNums"))
        End If

        loadTag = weblog("log_Tag")
        Set getTag = New Tag

        '清除旧的Tag
        If Len(loadTag)>0 Then
            loadTag = Replace(loadTag, "}{", ",")
            loadTag = Replace(loadTag, "}", "")
            loadTag = Replace(loadTag, "{", "")
            loadTags = Split(loadTag, ",")

            For Each post_tag in loadTags
                getTag.Remove post_tag
            Next
        End If
        Call Tags(2)
        Set getTag = Nothing
        Dim preLog, nextLog, WebFso
        Conn.Execute("DELETE * FROM blog_Content WHERE log_ID="&id)
        Conn.Execute("DELETE * FROM blog_Comment WHERE blog_ID="&id)
        
		Set WebFso = New cls_FSO
			WebFso.DeleteFile("post/"&logid&".asp")
			WebFso.DeleteFile("cache/"&logid&".asp")
			WebFso.DeleteFile("cache/c_"&logid&".js")
			If blog_postFile =2 Then WebFso.DeleteFile(pcmpad)
		Set WebFso = Nothing
	
        Set preLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime<#"&Pdate&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime DESC")
        Set nextLog = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime>#"&Pdate&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime ASC")
        '输出附近的日志到文件
        If Not preLog.EOF Then PostArticle preLog("log_ID"), False
        If Not nextLog.EOF Then PostArticle nextLog("log_ID"), False
        SQLQueryNums = SQLQueryNums + 5
        weblog.Close

        Call updateCache

        Session(CookieName&"_LastDo") = "DelArticle"
        session(CookieName&"_draft_"&logAuthor) = conn.Execute("select count(log_ID) from blog_Content where log_Author='"&logAuthor&"' and log_IsDraft=true")(0)
        SQLQueryNums = SQLQueryNums + 1
        deleteLog = Array(0, "删除成功!")

    End Function

    '*********************************************
    '获得日志
    '*********************************************

    Public Function getLog(id)
        Dim getTag
        getLog = Array( -3, "准备提取日志!")
        If IsEmpty(id) Then
            getLog = Array( -4, "ID号不能为空!")
            Exit Function
        End If

        If Not IsInteger(id) Then
            getLog = Array( -1, "非法ID号!")
            Exit Function
        End If

        sqlString = "SELECT top 1 log_CateID,log_Author,log_Title,log_EditType,log_UbbFlags,log_Intro,log_weather,log_Level,log_ComOrder,log_DisComment,log_IsShow,log_IsTop,log_IsDraft,log_From,log_FromURL,log_Content,log_Tag,log_PostTime,log_CommNums,log_QuoteNums,log_ViewNums,log_Readpw,log_Pwtips,log_Pwtitle,log_Pwcomm,log_Cname,log_Ctype,log_KeyWords,log_Description,log_Meta FROM blog_Content WHERE log_ID="&id&""
        weblog.Open sqlString, Conn, 1, 1
        SQLQueryNums = SQLQueryNums + 1

        If weblog.EOF Or weblog.bof Then
            getLog = Array( -2, "找不到相应文章!")
            Exit Function
        End If

        categoryID = weblog("log_CateID")
        logAuthor = weblog("log_Author")
        logTitle = weblog("log_Title")
        logEditType = weblog("log_EditType")
        logIntroCustom = Mid(weblog("log_UbbFlags"), 6, 1)
        logIntro = weblog("log_Intro")
        logWeather = weblog("log_weather")
        logLevel = weblog("log_Level")
        logCommentOrder = weblog("log_ComOrder")
        logDisableComment = weblog("log_DisComment")
        logIsShow = weblog("log_IsShow")
        logIsTop = weblog("log_IsTop")
        logIsDraft = weblog("log_IsDraft")
        logFrom = weblog("log_From")
        logFromURL = weblog("log_FromURL")
        logDisableImage = Mid(weblog("log_UbbFlags"), 3, 1)
        logDisableSmile = Mid(weblog("log_UbbFlags"), 1, 1)
        logDisableURL = Mid(weblog("log_UbbFlags"), 4, 1)
        logDisableKeyWord = Mid(weblog("log_UbbFlags"), 5, 1)
        logMessage = weblog("log_Content")
        logCommentCount = weblog("log_CommNums")
        logQuoteCount = weblog("log_QuoteNums")
        logViewCount = weblog("log_ViewNums")
		logCname = weblog("log_Cname")
		logCtype = weblog("log_Ctype")
        logReadpw = Trim(weblog("log_Readpw"))
        logPwtips = weblog("log_Pwtips")
        logPwtitle = weblog("log_Pwtitle")
        logPwcomm = weblog("log_Pwcomm")
		logmeta = weblog("log_Meta")
		logKeyWords = weblog("log_KeyWords")
		logDescription = weblog("log_Description")
        logTrackback = ""
        Set getTag = New Tag
        logTags = getTag.filterEdit(weblog("log_Tag"))
        Set getTag = Nothing
        logPubTime = weblog("log_PostTime")
        logPublishTimeType = "now"

        weblog.Close
        getLog = Array(0, "成功获取日志!")

    End Function

    '*********************************************
    '删除文件
    '*********************************************

    Private Function DeleteFiles(FilePath)
        Dim FSO
        Set FSO = Server.CreateObject("Scripting.FileSystemObject")
        If FSO.FileExists(FilePath) Then
            FSO.DeleteFile FilePath, True
            DeleteFiles = True
        Else
            DeleteFiles = False
        End If
        Set FSO = Nothing
    End Function

    '*********************************************
    '更新缓存
    '*********************************************

    Private Sub updateCache
        Call Archive(2)
        Call CategoryList(2)
        Call getInfo(2)
        Call NewComment(2)
        Call Calendar("", "", "", 2)
		Call BlogArticleID(2)

        If blog_postFile>0 Then
            Dim lArticle
            Set lArticle = New ArticleCache
            lArticle.SaveCache
            Set lArticle = Nothing
        End If
    End Sub

End Class
%>
<%
'======================================================
'  PJblog2 静态缓存类
'======================================================

Class ArticleCache
    Private cacheList
    Private cacheStream
    Private errorCode
    
    Private Sub Class_Initialize()
        cacheList = ""
    End Sub

    Private Sub Class_Terminate()

    End Sub

    Private Function clearT(Str)
        Dim tempLen
        tempLen = Len(Str)
        If tempLen>0 Then
            Str = Left(Str, tempLen -1)
        End If
        clearT = Str
    End Function
    
    Private Function LoadIntro(id, Cpart, Cname, Ctype, aisshow, aRight, outType)
        Dim getIntro, tempI, TempStr, getC, author
        If not IsEmpty(Application(CookieName&"_introCache_"&id)) then
        	getIntro = Application(CookieName&"_introCache_"&id)
        Else 
		    If IsBlank(Cpart) then
			   getIntro = LoadFile("cache/" & id & ".asp")
			Else
       	       getIntro = LoadFile("cache/" & id & ".asp")
			End If
       	End If
        If getIntro = "error" or getIntro="" Then
            If stat_Admin Then
                response.Write "<div style=""color:#f00"">编号为[" + id + "]的日志读取失败！建议您重新 <a href=""blogedit.asp?id="&id&""" title=""编辑该日志"" accesskey=""E"">编辑</a> 此文章获得新的缓存</div>"
            End If
            Exit Function
        End If
        getIntro = Split(getIntro, "<"&"%ST(A)%"&">")
        author = Trim(getIntro(1))
        If outType = "list" Then
            If CBool(Int(aRight)) Or stat_Admin Or (Not CBool(Int(aRight)) And memName = author) Then
                tempI = getIntro(4)
            Else
                tempI = getIntro(6)
            End If
			
			'evio
			Dim ceeurl2, chtml2
			chtml2 = Ctype

			If blog_postFile = 2 and aisshow = "True" then
			   ceeurl2 = CreateUrl(cpart, cname, chtml2)
			Else
			   ceeurl2 = "article.asp?id=" & id
			End If
			tempI = Replace(tempI, "<$log_ceeurl$>", ceeurl2)
			'evio
            tempI = Replace(tempI, "<$log_viewC$>", getIntro(2))
            response.Write tempI
        Else
            TempStr = ""
            If stat_EditAll Or (stat_Edit And memName = author) Then
                TempStr = TempStr&" | <a href=""blogedit.asp?id="&id&"""><img src=""images/icon_edit.gif"" alt="""" border=""0"" style=""margin-bottom:-2px""/></a>"
            End If

            If stat_DelAll Or (stat_Del And memName = author) Then
                TempStr = TempStr&" | <a href=""blogedit.asp?action=del&amp;id="&id&""" onclick=""if (!window.confirm('是否要删除该日志')) return false""><img src=""images/icon_del.gif"" alt="""" border=""0"" style=""margin-bottom:-2px""/></a>"
            End If
            If CBool(Int(aRight)) Or stat_Admin Or (Not CBool(Int(aRight)) And memName = author) Then
                tempI = getIntro(3)
            Else
                tempI = getIntro(5)
            End If
			'evio
			Dim ceeurl, chtml
		        chtml = Ctype
				
			If blog_postFile = 2 and aisshow = "True" then
			   ceeurl = CreateUrl(cpart, cname, chtml)
			Else
			   ceeurl = "article.asp?id=" & id
			End If
			tempI = Replace(tempI, "<$log_ceeurl$>", ceeurl)
			'evio
            tempI = Replace(tempI, "<"&"%Article In PJblog2%"&">", "")
            tempI = Replace(tempI, "<$editRight$>", TempStr)
            tempI = Replace(tempI, "<$log_viewC$>", getIntro(2))
            response.Write tempI
        End If
    End Function

    Private Function LoadFile(ByVal File)
        On Error Resume Next
        LoadFile = "error"
        With cacheStream
            .Type = 2
            .Mode = 3
            .Open
            .Charset = "utf-8"
            .Position = cacheStream.Size
            .LoadFromFile Server.MapPath(File)
            If Err Then
                .Close
                Err.Clear
                Exit Function
            End If
            LoadFile = .ReadText
            .Close
        End With
    End Function

    Public Function outHTML(loadType, outType, title)
        Dim re, strMatchs, strMatch, i, j, id, aRight, hiddenC , aCpart, aCname, aCtype, aisshow
        Set cacheStream = Server.CreateObject("ADODB.Stream")
        Set re = New RegExp
        re.IgnoreCase = True
        re.Global = True
        re.Pattern = "\[""([^\r]*?)"";([^\r]*?);\(([^\r]*?)\)\]"
        Set strMatchs = re.Execute(cacheList)
        For Each strMatch in strMatchs
            If loadType = strMatch.SubMatches(0) Then
                Dim aList, pageSize
                pageSize = blogPerPage
                If outType = "list" Then pageSize = pageSize * 4
                aList = Split(strMatch.SubMatches(2), ",")
                hiddenC = strMatch.SubMatches(1)
                If stat_Admin Or stat_ShowHiddenCate Then hiddenC = 0
                If (UBound(aList) + 1 - hiddenC)>0 Then

%>

<div class="pageContent" style="text-align:Right;overflow:hidden;height:18px;line-height:140%"><span style="float:left"><%=title%></span>预览模式: <a href="<%=Url_Add%>distype=normal" accesskey="1">普通</a> | <a href="<%=Url_Add%>distype=list" accesskey="2">列表</a></div>
<%
If outType = "list" Then response.Write "<div class=""Content-body"" style=""text-align:Left""><table cellpadding=""2"" cellspacing=""2"" width=""100%"">"
i = 0
Do Until i >= pageSize
    j = i + (CurPage -1) * pageSize
    If j<= UBound(aList) Then
        id = Split(aList(j), "|")(1)
        aRight = Split(aList(j), "|")(0)
        aCpart = Split(aList(j), "|")(2)
        aCname = Split(aList(j), "|")(3)
        aCtype = Split(aList(j), "|")(4)
        aisshow = Split(aList(j), "|")(5)
        LoadIntro id, aCpart, aCname, aCtype, aisshow, aRight, outType
        i = i + 1
    Else
        If outType = "list" Then response.Write "</table></div>"

%>
<div class="pageContent"><%=MultiPage(ubound(aList)+1-hiddenC,pageSize,CurPage,Url_Add,"","float:Left","")%></div>
<%
Exit For
End If
Loop
If outType = "list" Then response.Write "</table></div>"

%>
<div class="pageContent"><%=MultiPage(ubound(aList)+1-hiddenC,pageSize,CurPage,Url_Add,"","float:Left","")%></div>
<%
Else
    response.Write "<b>抱歉，没有找到任何日志！</b>"
End If
Set re = Nothing
Exit Function
End If
Next
Set re = Nothing
Set cacheStream = Nothing
End Function

Public Function loadCache
    Dim LoadList
    If blog_postFile<1 Then
        loadCache = False
        Exit Function
    End If
    

    If not isEmpty(Application(CookieName&"_listCache")) then
   		LoadList = Array(0,Application(CookieName&"_listCache"))
    Else
   		LoadList = LoadFromFile("cache/listCache.asp")
    End If
    
    If LoadList(0) = 0 Then
        cacheList = LoadList(1)
        loadCache = True
    Else
        loadCache = False
    End If
End Function

Public Function SaveCache
    If blog_postFile<1 Then Exit Function
    Dim LogList, LogListArray, SaveList, CateDic, CateHDic, TagsDic
    Set CateDic = Server.CreateObject("Scripting.Dictionary")
    Set CateHDic = Server.CreateObject("Scripting.Dictionary")
    Set TagsDic = Server.CreateObject("Scripting.Dictionary")

    SQL = "select T.log_ID,T.log_CateID,T.log_IsShow,C.cate_Secret,C.cate_part,T.log_Cname,T.log_Ctype FROM blog_Content As T,blog_Category As C where T.log_CateID=C.cate_ID and log_IsDraft=false ORDER BY log_IsTop ASC,log_PostTime DESC"
    Set LogList = conn.Execute(SQL)
    If LogList.EOF Or LogList.BOF Then
    	dim temp1 
    	temp1 = "[""A"";0;()]" & Chr(13) & "[""G"";0;()]"
        SaveList = SaveToFile(temp1, "cache/listCache.asp")
'       If memoryCache = true then
			Application.Lock
			Application(CookieName&"_listCache") = temp1
			Application.UnLock
'       End If
        Set LogList = Nothing
        Exit Function
    End If
    LogListArray = LogList.GetRows()
    Set LogList = Nothing
    Dim i, AList, AListC, GList, GListC, outIndex, tempS, tempCS, hiddenC, Cnames_l
    AList = ""
    AListC = 0
    GList = ""
    GListC = 0
    outIndex = ""
    For i = 0 To UBound(LogListArray, 2)
        tempS = 1
        hiddenC = 1
        'response.write LogListArray(0,i) & " "
        If Not LogListArray(2, i) Then tempS = 0
        If Not LogListArray(3, i) Then
            tempCS = 0
            hiddenC = 0
			
			If IsBlank(trim(LogListArray(5, i))) Then
				Cnames_l = trim(LogListArray(0, i))
			Else
				Cnames_l = trim(LogListArray(5, i))
			End If
			GList = GList & tempS & "|" & LogListArray(0, i) & "|" & trim(LogListArray(4, i)) & "|" & Cnames_l & "|" & LogListArray(6, i) & "|" & LogListArray(2, i) & ","
            GListC = GListC + hiddenC
        End If

        AList = AList & tempS & "|" & LogListArray(0, i) & "|" & trim(LogListArray(4, i)) & "|" & Cnames_l & "|" & LogListArray(6, i) & "|" & LogListArray(2, i) & ","
        AListC = AListC + hiddenC
        If Not CateDic.Exists("C"&LogListArray(1, i)) Then
            CateDic.Add "C"&LogListArray(1, i), tempS & "|" & LogListArray(0, i) & "|" & trim(LogListArray(4, i)) & "|" & Cnames_l & "|" & LogListArray(6, i) & "|" & LogListArray(2, i) &","
        Else
            CateDic.Item("C"&LogListArray(1, i)) = CateDic.Item("C"&LogListArray(1, i)) & tempS & "|" & LogListArray(0, i) & "|" & trim(LogListArray(4, i)) & "|" & Cnames_l & "|" & LogListArray(6, i) & "|" & LogListArray(2, i) & ","
        End If

        If Not CateHDic.Exists("CH"&LogListArray(1, i)) Then
            CateHDic.Add "CH"&LogListArray(1, i), hiddenC
        Else
            CateHDic.Item("CH"&LogListArray(1, i)) = CateHDic.Item("CH"&LogListArray(1, i)) + hiddenC
        End If

    Next
    outIndex = outIndex & "[""A"";"&AListC&";("&clearT(AList)&")] " & Chr(13)
    outIndex = outIndex & "[""G"";"&GListC&";("&clearT(GList)&")] " & Chr(13)
    Dim CateKeys, CateItems, CateHKeys, CateHItems
    CateKeys = CateDic.Keys
    CateItems = CateDic.Items
    CateHKeys = CateHDic.Keys
    CateHItems = CateHDic.Items
    For i = 0 To CateDic.Count -1
        outIndex = outIndex & "["""&CateKeys(i)&""";"&CateHItems(i)&";("&clearT(CateItems(i))&")] " & Chr(13)
    Next

    SaveList = SaveToFile(outIndex, "cache/listCache.asp")
    
'   If memoryCache = true then
		Application.Lock
		Application(CookieName&"_listCache") = outIndex
		Application.UnLock
'   End If 
	
    Set CateDic = Nothing
    Set CateHDic = Nothing
    Set TagsDic = Nothing
    
    call newEtag
End Function

End Class
%>
<%
'======================================================
'  PJblog2 动态文章保存
'======================================================

Sub PostArticle(ByVal LogID, ByVal UpdateListOnly)
    If blog_postFile = 1 Then
        PostHalfStatic LogID, UpdateListOnly
    ElseIf blog_postFile = 2 Then
        PostFullStatic LogID, UpdateListOnly
    End If
    
    call newEtag
End Sub

'======================================================
'半静态化
'======================================================

Sub PostHalfStatic(ByVal LogID, ByVal UpdateListOnly)
    Dim SaveArticle, LoadTemplate1, Temp1, TempStr, log_View, preLogC, nextLogC

    '读取日志模块
    LoadTemplate1 = LoadFromFile("Template/Article.asp")

    If LoadTemplate1(0) <> 0 Then Exit Sub'读取成功后写入信息

    '读取分类信息
    Temp1 = LoadTemplate1(1)

    '读取日志内容
    SQL = "SELECT TOP 1 * FROM blog_Content WHERE log_ID=" & LogID
    SQLQueryNums = SQLQueryNums + 1

    Set log_View = conn.Execute(SQL)
    Dim blog_Cate, blog_CateArray, comDesc
    Dim getCate, getTags

    Set getCate = New Category
    Set getTags = New Tag
    getCate.load(Int(log_View("log_CateID"))) '获取分类信息
    	
	If UpdateListOnly then '只更新列表缓存
	    PostArticleListCache LogID, log_View, getCate, getTags
	
	    Set log_View = Nothing
	    Set getCate = Nothing
	    Set getTags = Nothing
	    exit Sub
	End If 
	


    Temp1 = Replace(Temp1, "<$Cate_icon$>", getCate.cate_icon)
    Temp1 = Replace(Temp1, "<$Cate_Title$>", getCate.cate_Name)
    Temp1 = Replace(Temp1, "<$log_CateID$>", log_View("log_CateID"))
    Temp1 = Replace(Temp1, "<$LogID$>", LogID)
    Temp1 = Replace(Temp1, "<$log_Title$>", HtmlEncode(log_View("log_Title")))
    Temp1 = Replace(Temp1, "<$log_Author$>", log_View("log_Author"))
    Temp1 = Replace(Temp1, "<$log_PostTime$>", DateToStr(log_View("log_PostTime"), "Y-m-d"))

    Temp1 = Replace(Temp1, "<$log_weather$>", log_View("log_weather"))
    Temp1 = Replace(Temp1, "<$log_level$>", log_View("log_level"))
    Temp1 = Replace(Temp1, "<$log_IsShow$>", log_View("log_IsShow"))

    If log_View("log_IsShow") and not getCate.cate_Secret Then
        Temp1 = Replace(Temp1, "<$log_hiddenIcon$>", "")
    Else
     	If log_View("log_Readpw") <> "" then
        	Temp1 = Replace(Temp1, "<$log_hiddenIcon$>", "<img src=""images/icon_lock2.gif"" style=""margin:0px 0px -3px 2px;"" alt=""加密日志"" />")
     	Else
        	Temp1 = Replace(Temp1, "<$log_hiddenIcon$>", "<img src=""images/icon_lock1.gif"" style=""margin:0px 0px -3px 2px;"" alt=""私密日志"" />")
        End If
    End If

    If Len(log_View("log_Tag"))>0 Then
        Temp1 = Replace(Temp1, "<$log_tag$>", getTags.filterHTML(log_View("log_Tag")))
    Else
        Temp1 = Replace(Temp1, "<$log_tag$>", "")
    End If

    If log_View("log_ComOrder") Then comDesc = "Desc" Else comDesc = "Asc" End If

    Temp1 = Replace(Temp1, "<$comDesc$>", comDesc)
    Temp1 = Replace(Temp1, "<$log_DisComment$>", log_View("log_DisComment"))

    If log_View("log_EditType") = 1 Then
        Temp1 = Replace(Temp1, "<$ArticleContent$>", UBBCode(HtmlEncode(log_View("log_Content")), Mid(log_View("log_UbbFlags"), 1, 1), Mid(log_View("log_UbbFlags"), 2, 1), Mid(log_View("log_UbbFlags"), 3, 1), Mid(log_View("log_UbbFlags"), 4, 1), Mid(log_View("log_UbbFlags"), 5, 1)))
    Else
        Temp1 = Replace(Temp1, "<$ArticleContent$>", UnCheckStr(log_View("log_Content")))
    End If

    If Len(log_View("log_Modify"))>0 Then
        Temp1 = Replace(Temp1, "<$log_Modify$>", "<div class=""Modify"">"&log_View("log_Modify")&"</div>")
    Else
        Temp1 = Replace(Temp1, "<$log_Modify$>", "")
    End If

    If Len(log_View("log_FromUrl"))>0 Then
        Temp1 = Replace(Temp1, "<$log_FromUrl$>", log_View("log_FromUrl"))
    Else
        Temp1 = Replace(Temp1, "<$log_FromUrl$>", "")
    End If

    Temp1 = Replace(Temp1, "<$log_From$>", log_View("log_From"))
    Temp1 = Replace(Temp1, "<$trackback$>", SiteURL&"trackback.asp?tbID="&LogID&"&amp;action=view")

    Temp1 = Replace(Temp1, "<$log_CommNums$>", log_View("log_CommNums"))
    Temp1 = Replace(Temp1, "<$log_QuoteNums$>", log_View("log_QuoteNums"))

    Temp1 = Replace(Temp1, "<$log_IsDraft$>", log_View("log_IsDraft"))

    Set preLogC = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime<#"&DateToStr(log_View("log_PostTime"), "Y-m-d H:I:S")&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime DESC")
    Set nextLogC = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime>#"&DateToStr(log_View("log_PostTime"), "Y-m-d H:I:S")&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime ASC")

    Dim BTemp,urlLink
    BTemp = ""

    If Not preLogC.EOF Then
    	If blog_postFile = 2 then
    		urlLink = Alias(preLogC("log_ID"))
    	Else 
    		urlLink = "?id="&preLogC("log_ID")
    	End If
        BTemp = BTemp & "<img border=""0"" src=""images/Cprevious.gif"" alt=""""/><strong>上一篇:</strong> <a href="""&urlLink&""" accesskey="","">"&preLogC("log_Title")&"</a><br/>"
    Else
        BTemp = BTemp & "<img border=""0"" src=""images/Cprevious1.gif""/><strong>上一篇:</strong> <i>这是最早的一篇日志</i><br/>"
    End If

    If Not nextLogC.EOF Then
    	If blog_postFile = 2 then
    		urlLink = Alias(nextLogC("log_ID"))
    	Else 
    		urlLink = "?id="&nextLogC("log_ID")
    	End If
        BTemp = BTemp & "<img border=""0"" src=""images/Cnext.gif"" alt=""""/><strong>下一篇:</strong> <a href="""&urlLink&""" accesskey=""."">"&nextLogC("log_Title")&"</a><br/>"
    Else
        BTemp = BTemp & "<img border=""0"" src=""images/Cnext1.gif""/><strong>下一篇:</strong> <i>这是最新的一篇日志</i><br/>"
    End If

    Temp1 = Replace(Temp1, "<$log_Navigation$>", BTemp)

    SaveArticle = SaveToFile(Temp1, "post/" & LogID & ".asp")

    PostArticleListCache LogID, log_View, getCate, getTags

    Set log_View = Nothing
    Set getCate = Nothing
    Set getTags = Nothing
    'getCate.cate_Secret or (not log_View("Log_IsShow"))
End Sub

'======================================================
'全静态化
'======================================================

Sub PostFullStatic(ByVal LogID, ByVal UpdateListOnly)
    Dim SaveArticle, LoadTemplate1, Temp1, TempStr, log_View, preLogC, nextLogC, Category,baseUrl, SavesFso
    
    '读取日志模块
    LoadTemplate1 = LoadFromFile("Template/Static.htm")

    If LoadTemplate1(0) <> 0 Then Exit Sub'读取成功后写入信息
    
    '静态页面特有的属性
	baseUrl = "http://" & Request.ServerVariables("HTTP_HOST") & Request.ServerVariables("URL")
	baseUrl = Left(baseUrl, InStrRev(baseUrl,"/"))
	
    '读取分类信息
    Temp1 = LoadTemplate1(1)

    '读取日志内容
    SQL = "SELECT TOP 1 * FROM blog_Content WHERE log_ID=" & LogID
    SQLQueryNums = SQLQueryNums + 1
	
    Set log_View = conn.Execute(SQL)
    
    blog_currentCategoryID = log_View("log_CateID")
    Dim blog_Cate, blog_CateArray, comDesc, CanRead
    Dim getCate, getTags
	
	Dim p_cname
	p_cname = log_View("log_cname").value
	If IsBlank(p_cname) Then p_cname = LogID
	
    Set getCate = New Category
    Set getTags = New Tag

    getCate.load(Int(log_View("log_CateID"))) '获取分类信息
    
	If UpdateListOnly then '只更新列表缓存
		PostArticleListCache LogID, log_View, getCate, getTags
		
	    Set log_View = Nothing
	    Set getCate = Nothing
	    Set getTags = Nothing
	    exit Sub
	End If 

	If log_View("log_IsShow") = false or getCate.cate_Secret then '如果是私密日志
    	SaveArticle = SaveToFile("<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN"">"& vbcrlf &_
    	"<html><head><title>加载私密日志</title>"& vbcrlf &_
    	"<style type=""text/css"">"& vbcrlf &_
    	"#out{width:400px;height:20px;background:#EEE;border:1px #206CFF solid;}"& vbcrlf &_
    	"#in{width:10px;height:20px;background:#206CFF;color:white;text-align:right;font-weight:bold;padding-right:5px;font-family:Arial;}"& vbcrlf &_
    	"#body{position:absolute;left:expression(document.body.clientWidth/2-210);top:expression(document.body.clientHeight/2-100);border:1px dotted #206CFF;padding:20px;color:#206CFF;background:#EEFCFF;}"& vbcrlf &_
    	"</style></head>"& vbcrlf &_
    	"<body onLoad=""loadarticle();"" >"& vbcrlf &_
    	"<div id=""body""><h3>请稍候...正在加载私密日志</h3>"& vbcrlf &_
    	"<div id=""out""><div id=""in"" style=""width:10%"">10%</div></div>"& vbcrlf &_
    	"<script type=""text/javascript"">"& vbcrlf &_
    	"function loadarticle(){"& vbcrlf &_
    	"	i=0;"& vbcrlf &_
    	"	ba=setInterval(""begin()"",5);"& vbcrlf &_
    	"}"& vbcrlf &_
    	"function begin(){"& vbcrlf &_
    	"	i+=1;"& vbcrlf &_
    	"	if(i<=100)"& vbcrlf &_
    	"	{"& vbcrlf &_
    	"	document.getElementById(""in"").style.width=i+""%"";"& vbcrlf &_
    	"	document.getElementById(""in"").innerHTML=i+""%"";}"& vbcrlf &_
    	"	else"& vbcrlf &_
    	"	{"& vbcrlf &_
    	"	clearInterval(ba);"& vbcrlf &_
    	"	document.getElementById(""out"").style.display=""none"";"& vbcrlf &_
    	"	  document.write( ""\<SCRIPT>"" );"& vbcrlf &_
    	"	  document.write( ""window.location.href='"&baseUrl&"article.asp?id="&LogID&"'"");"& vbcrlf &_
    	"	  document.write( ""\</SCRIPT\>"" );"& vbcrlf &_
    	"	}"& vbcrlf &_
    	"}"& vbcrlf &_
    	"</script>"& vbcrlf &_
    	"</div></body></html>", CreateUrl(getCate.cate_Part, p_cname, log_View("log_ctype")))
    	PostHalfStatic LogID, UpdateListOnly
	    Set log_View = Nothing
	    exit Sub
	End If
	
    If log_View("log_ComOrder") Then comDesc = "Desc" Else comDesc = "Asc" End If	
    
    Temp1 = Replace(Temp1, "<$CategoryList$>", CategoryList(0))
    Temp1 = Replace(Temp1, "<$base$>", baseUrl)
    Temp1 = Replace(Temp1, "<$siteName$>", siteName)
    Temp1 = Replace(Temp1, "<$siteURL$>", siteURl)
    Temp1 = Replace(Temp1, "<$blog_Title$>", blog_Title)
    Temp1 = Replace(Temp1, "<$blog_email$>", blog_email)
    Temp1 = Replace(Temp1, "<$blog_master$>", blog_master)
    Temp1 = Replace(Temp1, "<$skin$>", blog_DefaultSkin)
    If Len(blogabout) > 0 Then Temp1 = Replace(Temp1, "<$blogabout$>", blogabout) Else Temp1 = Replace(Temp1, "<$blogabout$>", "")
    Temp1 = Replace(Temp1, "<$comDesc$>", comDesc)
    Temp1 = Replace(Temp1, "<$CookieName$>", CookieName)
    Temp1 = Replace(Temp1, "<$blog_version$>", blog_version)
    
   '输出第一页评论

    Temp1 = Replace(Temp1, "<$comment$>", ShowComm(LogID, comDesc, log_View("log_DisComment"), True, log_View("log_IsShow"), log_View("log_Readpw"), CanRead, False))   
    Temp1 = Replace(Temp1, "<$blog_commLength$>", blog_commLength)
    If (blog_commUBB=0) Then
    	Temp1 = Replace(Temp1, "<$blog_commUBB$>", "开启")
    Else
    	Temp1 = Replace(Temp1, "<$blog_commUBB$>", "关闭")
    End If
    If (blog_commIMG=0) Then
    	Temp1 = Replace(Temp1, "<$blog_commIMG$>", "开启")
    Else
    	Temp1 = Replace(Temp1, "<$blog_commIMG$>", "关闭")
    End If
    Temp1 = Replace(Temp1, "<$Cate_icon$>", getCate.cate_icon)
    Temp1 = Replace(Temp1, "<$Cate_Title$>", getCate.cate_Name)
    Temp1 = Replace(Temp1, "<$log_CateID$>", log_View("log_CateID"))
    Temp1 = Replace(Temp1, "<$LogID$>", LogID)
    Temp1 = Replace(Temp1, "<$log_Title$>", HtmlEncode(log_View("log_Title")))
    Temp1 = Replace(Temp1, "<$log_Author$>", log_View("log_Author"))
    Temp1 = Replace(Temp1, "<$log_PostTime$>", DateToStr(log_View("log_PostTime"), "Y-m-d"))

    Temp1 = Replace(Temp1, "<$log_weather$>", log_View("log_weather"))
    Temp1 = Replace(Temp1, "<$log_level$>", log_View("log_level"))
	If not isblank(log_View("log_KeyWords")) Then
		Temp1 = Replace(Temp1, "<$keywords$>", trim(log_View("log_KeyWords"))&","&blog_KeyWords)
    Else
		Temp1 = Replace(Temp1, "<$keywords$>", blog_KeyWords)
	End If
	If not isblank(log_View("log_Description"))  and log_View("log_IsShow") = True Then
		Temp1 = Replace(Temp1, "<$description$>", CheckStr(replace(UnCheckStr(trim(log_View("log_Description"))),vbcrlf,""))&",")
    Else
		Temp1 = Replace(Temp1, "<$description$>", "")
	End If

    If Len(log_View("log_Tag"))>0 Then
        Temp1 = Replace(Temp1, "<$log_tag$>", getTags.filterHTML(log_View("log_Tag")))
    Else
        Temp1 = Replace(Temp1, "<$log_tag$>", "")
    End If

    Temp1 = Replace(Temp1, "<$comDesc$>", comDesc)
    Temp1 = Replace(Temp1, "<$log_DisComment$>", log_View("log_DisComment"))

    If log_View("log_EditType") = 1 Then
        Temp1 = Replace(Temp1, "<$ArticleContent$>", UBBCode(HtmlEncode(log_View("log_Content")), Mid(log_View("log_UbbFlags"), 1, 1), Mid(log_View("log_UbbFlags"), 2, 1), Mid(log_View("log_UbbFlags"), 3, 1), Mid(log_View("log_UbbFlags"), 4, 1), Mid(log_View("log_UbbFlags"), 5, 1)))
    Else
        Temp1 = Replace(Temp1, "<$ArticleContent$>", UnCheckStr(log_View("log_Content")))
    End If

    If Len(log_View("log_Modify"))>0 Then
        Temp1 = Replace(Temp1, "<$log_Modify$>", "<div class=""Modify"">"&log_View("log_Modify")&"</div>")
    Else
        Temp1 = Replace(Temp1, "<$log_Modify$>", "")
    End If

	If Len(log_View("log_FromUrl")) > 0 Then
	    Temp1 = Replace(Temp1, "<$log_FromUrl$>", log_View("log_FromUrl"))
	Else
	    Temp1 = Replace(Temp1, "<$log_FromUrl$>", "")
	End If
    Temp1 = Replace(Temp1, "<$log_From$>", log_View("log_From"))
    Temp1 = Replace(Temp1, "<$trackback$>", SiteURL&"trackback.asp?tbID="&LogID&"&amp;action=view")

    Temp1 = Replace(Temp1, "<$log_CommNums$>", log_View("log_CommNums"))
    Temp1 = Replace(Temp1, "<$log_QuoteNums$>", log_View("log_QuoteNums"))

    Temp1 = Replace(Temp1, "<$log_IsDraft$>", log_View("log_IsDraft"))

    Set preLogC = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime<#"&DateToStr(log_View("log_PostTime"), "Y-m-d H:I:S")&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime DESC")
    Set nextLogC = Conn.Execute("SELECT TOP 1 T.log_Title,T.log_ID FROM blog_Content As T,blog_Category As C WHERE T.log_PostTime>#"&DateToStr(log_View("log_PostTime"), "Y-m-d H:I:S")&"# and T.log_CateID=C.cate_ID and (T.log_IsShow=true or T.log_Readpw<>'') and C.cate_Secret=False and T.log_IsDraft=false ORDER BY T.log_PostTime ASC")

    Dim BTemp
    BTemp = ""
    If Not preLogC.EOF Then
        BTemp = BTemp & "<img border=""0"" src=""images/Cprevious.gif"" alt=""""/><strong>上一篇:</strong> <a href="""&Alias(preLogC("log_ID"))&""" accesskey="","">"&preLogC("log_Title")&"</a><br/>"
    Else
        BTemp = BTemp & "<img border=""0"" src=""images/Cprevious1.gif""/><strong>上一篇:</strong> <i>这是最早的一篇日志</i><br/>"
    End If

    If Not nextLogC.EOF Then
        BTemp = BTemp & "<img border=""0"" src=""images/Cnext.gif"" alt=""""/><strong>下一篇:</strong> <a href="""&Alias(nextLogC("log_ID"))&""" accesskey=""."">"&nextLogC("log_Title")&"</a><br/>"
    Else
        BTemp = BTemp & "<img border=""0"" src=""images/Cnext1.gif""/><strong>下一篇:</strong> <i>这是最新的一篇日志</i><br/>"
    End If

    Temp1 = Replace(Temp1, "<$log_Navigation$>", BTemp)
	
	Set SavesFso = New cls_FSO
		If Len(getCate.cate_Part) > 0 Then SavesFso.CreateFolder("article/" & getCate.cate_Part & "/")
	Set SavesFso = Nothing

    SaveArticle = SaveToFile(Temp1, CreateUrl(getCate.cate_Part, p_cname, log_View("log_ctype")))

    PostArticleListCache LogID, log_View, getCate , getTags

    Set log_View = Nothing
    Set getCate = Nothing
    Set getTags = Nothing
    'getCate.cate_Secret or (not log_View("Log_IsShow"))
End Sub

'======================================================
'缓存静态化列表
'======================================================

Sub PostArticleListCache(ByVal LogID,ByVal log_View,ByVal getCate,ByVal getTags)
    Dim LoadTemplate2, Temp2, comDesc, SaveArticle
    LoadTemplate2 = LoadFromFile("Template/ArticleList.asp")
    If LoadTemplate2(0) <> 0 Then Exit Sub
    Temp2 = LoadTemplate2(1)
    Temp2 = Replace(Temp2, "<$Cate_icon$>", getCate.cate_icon)
    Temp2 = Replace(Temp2, "<$Cate_Title$>", getCate.cate_Name)
    Temp2 = Replace(Temp2, "<$log_CateID$>", log_View("log_CateID"))
    Temp2 = Replace(Temp2, "<$LogID$>", LogID)
    Temp2 = Replace(Temp2, "<$log_Title$>", HtmlEncode(log_View("log_Title")))
    Temp2 = Replace(Temp2, "<$log_Author$>", log_View("log_Author"))
    Temp2 = Replace(Temp2, "<$log_PostTime$>", DateToStr(log_View("log_PostTime"), "Y-m-d"))
    Temp2 = Replace(Temp2, "<$log_viewCount$>", log_View("log_ViewNums"))
    
    'article.asp?id=<$LogID$>
    If blog_postFile = 2  and log_View("log_IsShow") and not getCate.cate_Secret Then
		If IsBlank(log_View("log_cname")) Then
    	    Temp2 = Replace(Temp2, "<$pLink$>", CreateUrl(getCate.cate_Part, LogID, log_View("log_ctype")))
		Else
	        Temp2 = Replace(Temp2, "<$pLink$>", CreateUrl(getCate.cate_Part, log_View("log_cname"), log_View("log_ctype")))
		End If
    Else
	 	Temp2 = Replace(Temp2, "<$pLink$>", "article.asp?id=" & LogID)
    End If 

    
    
    If log_View("log_IsTop") Then
        Temp2 = Replace(Temp2, "<$ShowButton$>", "<div class=""BttnE"" onclick=""TopicShow(this,'log_"&LogID&"')""></div>")
        Temp2 = Replace(Temp2, "<$ShowStyle$>", " style=""display:none""")
    Else
        Temp2 = Replace(Temp2, "<$ShowButton$>", "")
        Temp2 = Replace(Temp2, "<$ShowStyle$>", "")
    End If

    If log_View("log_IsShow") and not getCate.cate_Secret Then
        Temp2 = Replace(Temp2, "<$log_hiddenIcon$>", "")
    Else
	    If log_View("log_Readpw") <> "" Then
	        Temp2 = Replace(Temp2, "<$log_Secret$>", "该日志是加密日志，需要输入正确密码才可以查看！")
	        Temp2 = Replace(Temp2, "<$log_hiddenIcon$>", "<img src=""images/icon_lock2.gif"" style=""margin:0px 0px -3px 2px;"" alt=""加密日志"" />")
	    Else
	        Temp2 = Replace(Temp2, "<$log_Secret$>", "该日志是私密日志，只有博主或发布者可以查看！")
	        Temp2 = Replace(Temp2, "<$log_hiddenIcon$>", "<img src=""images/icon_lock1.gif"" style=""margin:0px 0px -3px 2px;"" alt=""私密日志"" />")
	    End If

	    If log_View("log_Pwtitle") = False Then
	        Temp2 = Replace(Temp2, "<$Show_Title$>", HtmlEncode(log_View("log_Title")))
	    ElseIf log_View("log_Readpw") <> "" Then
	        Temp2 = Replace(Temp2, "<$Show_Title$>", "[加密日志]")
	    Else
	        Temp2 = Replace(Temp2, "<$Show_Title$>", "[私密日志]")
	    End If
    End If

    If Len(log_View("log_Tag"))>0 Then
        Temp2 = Replace(Temp2, "<$log_tag$>", "<p class=""tags"">Tags: "&getTags.filterHTML(log_View("log_Tag"))&"</p>")
    Else
        Temp2 = Replace(Temp2, "<$log_tag$>", "")
    End If

    If log_View("log_ComOrder") Then comDesc = "Desc" Else comDesc = "Asc" End If

    If log_View("log_EditType") = 1 Then
        Temp2 = Replace(Temp2, "<$log_Intro$>", UnCheckStr(UBBCode(log_View("log_Intro"), Mid(log_View("log_UbbFlags"), 1, 1), Mid(log_View("log_UbbFlags"), 2, 1), Mid(log_View("log_UbbFlags"), 3, 1), Mid(log_View("log_UbbFlags"), 4, 1), Mid(log_View("log_UbbFlags"), 5, 1))))
        If log_View("log_Intro")<>HtmlEncode(log_View("log_Content")) Then
        
            If blog_postFile = 2 and log_View("log_IsShow") and not getCate.cate_Secret Then
          	   Temp2 = Replace(Temp2, "<$log_readMore$>", "<p class=""readMore""><a href="""&Alias(LogID)&""" class=""more""><span>查看更多...</span></a></p>")
			Else
          	   Temp2 = Replace(Temp2, "<$log_readMore$>", "<p class=""readMore""><a href=""article.asp?id="&LogID&""" class=""more""><span>查看更多...</span></a></p>")           
  			End If
  			
        Else
            Temp2 = Replace(Temp2, "<$log_readMore$>", "")
        End If
    Else
        Temp2 = Replace(Temp2, "<$log_Intro$>", UnCheckStr(log_View("log_Intro")))
        If log_View("log_Intro")<>log_View("log_Content") Then
            If blog_postFile = 2 and log_View("log_IsShow") and not getCate.cate_Secret Then
             	   Temp2 = Replace(Temp2, "<$log_readMore$>", "<p class=""readMore""><a href="""&Alias(LogID)&""" class=""more""><span>查看更多...</span></a></p>")
            Else
             	   Temp2 = Replace(Temp2, "<$log_readMore$>", "<p class=""readMore""><a href=""article.asp?id="&LogID&""" class=""more""><span>查看更多...</span></a></p>")
            End If
        Else
            Temp2 = Replace(Temp2, "<$log_readMore$>", "")
        End If
    End If

    Temp2 = Replace(Temp2, "<$log_CommNums$>", log_View("log_CommNums"))
    Temp2 = Replace(Temp2, "<$log_QuoteNums$>", log_View("log_QuoteNums"))

    SaveArticle = SaveToFile(Temp2, "cache/" & LogID & ".asp")
    
    If memoryCache = true then
		Application.Lock
		Application(CookieName&"_introCache_"&LogID) = Temp2
		Application.UnLock
	End If
End Sub

'======================================================
'模板文件保存到内存里
'======================================================

Sub LoadTemplateFile(Path)
    Dim cache
End Sub

%>