﻿<!--#include file = "../../include.asp" -->
<!--#include file = "../../pjblog.data/control/cls_template.asp" -->
<!--#include file = "../../pjblog.data/control/cls_plugin.asp" -->
<!--#include file = "../../pjblog.model/cls_fso.asp" -->
<!--#include file = "../../pjblog.model/cls_xml.asp" -->
<!--#include file = "../../pjblog.model/cls_Stream.asp" -->
<!--#include file = "../../pjblog.data/cls_plus.asp" -->
<%
Dim doTemp
Set doTemp = New do_Template
Set doTemp = Nothing

Class do_Template

	Private fso, cxml, OK

	Public Property Get Action
		Action = Request.QueryString("action")
	End Property
	
	' ***********************************************
	'	类初始化
	' ***********************************************
	Private Sub Class_Initialize
		Select Case Action
			Case "Choose" Call Choose
			Case "update" Call doUpdate
			Case "AddPlus" Call AddPlus
			Case "ImportPlus" Call ImportPlus
			Case "GetPlusCode" Call GetPlusCode
			Case "SavePlusCode" Call SavePlusCode
		End Select
    End Sub 
     
	' ***********************************************
	'	类终结化
	' ***********************************************
    Private Sub Class_Terminate
		Sys.Close
    End Sub
	
	Private Sub Choose
		Dim f1, ReturnStr, Arrays, m, Str, cname
		f1 = Trim(Asp.CheckStr(Request.Form("f1")))
		If Len(f1) > 0 Then
			Set fso = New cls_fso
			Set cxml = New xml
				ReturnStr = fso.FolderItem("../../pjblog.template/" & f1 & "/style")
				Arrays = Split(ReturnStr, "|")
				If Int(Arrays(0)) > 0 Then
					Str = ""
					On Error Resume Next
					For m = 1 To UBound(Arrays)
						If fso.FileExists("../../pjblog.template/" & f1 & "/style/" & Arrays(m) & "/style.xml") Then
							cxml.FilePath = "../../pjblog.template/" & f1 & "/style/" & Arrays(m) & "/style.xml"
							If cxml.open Then
								cname = cxml.GetNodeText(cxml.FindNode("//SkinSet/SkinName"))
								If Err Then Err.Clear : cname = ""
								If Arrays(m) = blog_style And blog_DefaultSkin = f1 Then
									Str = Str & "<div><input type=\'radio\' value=\'" & Arrays(m) & "\' name=\'f2\' checked>" & cname & "</div><br />"
								Else
									Str = Str & "<div><input type=\'radio\' value=\'" & Arrays(m) & "\' name=\'f2\'>" & cname & "</div><br />"
								End If
							End If
						End If
					Next
					If Len(Str) = 0 Then Response.Write("{Suc:false, Info:'没有样式'}") : Exit Sub
				Else
					Response.Write("{Suc:false, Info:'没有样式'}")
				End If
			Set cxml = Nothing
			Set fso = Nothing
			Response.Write("{Suc:true,Info:'" & Str & "'}")
		Else
			Response.Write("{Suc:false, Info:'路径错误'}")
		End If
	End Sub
	
	Private Sub doUpdate
		Dim f1, f2
		f1 = Trim(Asp.CheckStr(Request.Form("f1")))
		f2 = Trim(Asp.CheckStr(Request.Form("f2")))
		If Asp.IsBlank(f1) Or Asp.IsBlank(f2) Then
			Session(Sys.CookieName & "_ShowMsg") = True
			Session(Sys.CookieName & "_MsgText") = "应用主题失败, 请选择样式或主题!"
			RedirectUrl(RedoUrl)
		End If
		OK = Temp.doUpdate(f1, f2)
		Session(Sys.CookieName & "_ShowMsg") = True
		If OK(0) Then
			Cache.GlobalCache(2)
			Session(Sys.CookieName & "_MsgText") = "应用主题成功!"
		Else
			Session(Sys.CookieName & "_MsgText") = OK(1)
		End If
		RedirectUrl(RedoUrl)
	End Sub
	
	Private Sub AddPlus
		Dim f1, folder, pluginSingleMark, cStream
		Dim xmlPath, dc, cc, bb
		Dim Config_Template, obj_mode, temps, subtemp
		Dim tp_pluginSingleMark, tp_pluginSinglePath, tp_pluginSingleName, tp_pluginSingleTempPath, Plugin_Mark, tp_pluginSingleTempValue, tp_plugintag
		dc = "{Suc : false, Info : '操作失败'}"
		cc = Array(False, "操作失败")
		f1 = Trim(Asp.CheckUrl(Request.Form("f1")))
		folder = Trim(Asp.CheckUrl(Request.Form("folder")))
		pluginSingleMark = Trim(Asp.CheckUrl(Request.Form("tp_pluginSingleMark")))
		xmlPath = "../../pjblog.plugin/" & folder & "/install.xml"
		Set fso = New cls_fso
		Set cxml = New xml
		Set cStream = New Stream
			If fso.FileExists(xmlPath) Then
				cxml.FilePath = xmlPath
				If cxml.open Then
					Plugin_Mark = cxml.GetNodeText(cxml.FindNode("//Plugin/Mark"))
					If Err Then Err.Clear : Plugin_Mark = "&nbsp;"
					Set Config_Template = cxml.FindNode("//Plugin/Config/Template")
							If Lcase(cxml.GetAttribute(Config_Template, "do")) = "true" Then
								Set obj_mode = Config_Template.selectSingleNode("mode")
									If Lcase(cxml.GetAttribute(obj_mode, "do")) = "true" Then
										Set temps = obj_mode.getElementsByTagName("item")
											On Error Resume Next
											For Each subtemp In temps
												tp_pluginSingleMark = cxml.GetNodeText(subtemp.selectSingleNode("mark"))
													If Err Then Err.Clear : tp_pluginSingleMark = "&nbsp;"
												tp_pluginSinglePath = cxml.GetNodeText(subtemp.selectSingleNode("include"))
													If Err Then Err.Clear : tp_pluginSinglePath = "&nbsp;"
												tp_pluginSingleName = cxml.GetNodeText(subtemp.selectSingleNode("name"))
													If Err Then Err.Clear : tp_pluginSingleName = "&nbsp;"
												tp_pluginSingleTempPath = cxml.GetNodeText(subtemp.selectSingleNode("templatePath"))
													If Err Then Err.Clear : tp_pluginSingleTempPath = "&nbsp;"
												tp_plugintag = cxml.GetNodeText(subtemp.selectSingleNode("tag"))
													If Err Then Err.Clear : tp_plugintag = ""
												bb = cStream.LoadFile("../../pjblog.plugin/" & folder & "/" & tp_pluginSingleTempPath)
												tp_pluginSingleTempValue = Asp.CheckStr(bb) ' uncheckstr
													If Err Then Err.Clear : tp_pluginSingleTempValue = ""
												If 	tp_pluginSingleMark = pluginSingleMark Then
													cc = Temp.AddPlus(f1, tp_pluginSingleMark, tp_pluginSinglePath, tp_pluginSingleTempPath, folder, tp_pluginSingleName, Plugin_Mark, tp_pluginSingleTempValue, tp_plugintag)
													If cc(0) Then dc = "{Suc : true, Info : '操作成功'}"
												End If	
											Next
									End If
							End If
				End If
			End If
		Set cStream = Nothing
		Set cxml = Nothing
		Set fso = Nothing
		Session(Sys.CookieName & "_ShowMsg") = True
		If cc(0) Then
			Session(Sys.CookieName & "_MsgText") = "添加插件成功!"
		Else
			Session(Sys.CookieName & "_MsgText") = cc(1)
		End If
		Response.Write(dc)
	End Sub
	
	Private Sub ImportPlus
		Dim pluginSinglePath, i, Paths, PluginPath, dd, key
		dd = "{Suc:false,Info:'操作失败'}"
		pluginSinglePath = Split(Request.Form("pluginSinglePath"), ",")
		PluginPath = Split(Request.Form("PluginPath"), ",")
		key = Split(Request.Form("key"), ",")
		If UBound(pluginSinglePath) >= 0 Then
			On Error Resume Next
			For i = 0 To UBound(pluginSinglePath)
				Paths = "<!--" & chr(35) & "include file=""../pjblog.plugin/" & PluginPath(i) & "/" & pluginSinglePath(i) & """ -->"
				Plugin.WritePluginAsp key(i), Paths
			Next
			If Err.Number > 0 Then
				dd = "{Suc:false,Info:'" & Err.Description & "'}"
			Else
				dd = "{Suc:true,Info:'导入成功!'}"
			End If
		End If
		Response.Write(dd)
	End Sub
	
	Private Sub GetPlusCode
		Dim id, Rs
		id = Asp.CheckStr(Request.QueryString("id"))
		If Not Asp.IsInteger(id) Then
			Response.Write("{Suc:false,Info:'找到该标签'}")
			Exit Sub
		End If
		Set Rs = Conn.Execute("Select tp_pluginSingleTempValue From blog_tempPlugin Where tp_ID=" & id)
		If Rs.Bof Or Rs.Eof Then
			Response.Write("{Suc:false,Info:'找到该标签'}")
		Else
			Response.Write("{Suc:true,Info:'" & cee.encode(Rs(0).value) & "'}")
		End If
		Set Rs = Nothing
	End Sub
	
	Public Sub SavePlusCode
		Dim id, Content, OK, Arrays
		id = Trim(Asp.CheckStr(Request.QueryString("id")))
		If Not Asp.IsInteger(id) Then
			Response.Write("{Suc:false,Info:'找不到该模板代码'}")
			Exit Sub
		End If
		Content = Trim(Asp.CheckStr(Request.Form("Content")))
		Arrays = Array(Array("tp_pluginSingleTempValue", Content))
		OK = Sys.doRecord("blog_tempPlugin", Arrays, "update", "tp_ID", id)
		If Ok(0) Then
			plus.Reload
			Response.Write("{Suc:true,Info:'保存模板代码成功!'}")
		Else
			Response.Write("{Suc:false,Info:'" & OK(1) & "'}")
		End If
	End Sub
	
End Class
%>