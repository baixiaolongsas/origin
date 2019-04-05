/****************************************************************************/
/* The DEFAULT= parameter points to the folder containing the .XML files.   */  
/* In this example, the files were generated using the ExcelXP tagset.      */
/* The EXT= parameter specifies which type of file should be converted.     */
/* The %INCLUDE statement includes the macro to be invoked. The macro will  */ 
/* convert any file type that Excel can read such as HTML, XLS, CSV, XML and*/
/* and more.                                                                */
/****************************************************************************/
options noxwait noxsync; 
 
%macro convert_files(default=,ext=);
 
data _null_;
file "'&default\temp.vbs'";
put "set xlapp = CreateObject(""Excel.Application"")";
put "set fso = CreateObject(""scripting.filesystemobject"")";
put "set myfolder = fso.GetFolder(""&default"")";
put "set myfiles = myfolder.Files";
put "xlapp.DisplayAlerts = False";
put " ";
put "for each f in myfiles";
put "  ExtName = fso.GetExtensionName(f)";
put "  Filename= fso.GetBaseName(f)";
put "    if ExtName=""&ext"" then";
put "           set mybook = xlapp.Workbooks.Open(f.Path)"; 
put "           xlapp.Visible = false";
put "           mybook.SaveAs ""&default.\"" & Filename & "".xlsx"", 51";
put "    End If";
put "  Next";
put "  mybook.Close";
put "  xlapp.DisplayAlerts = True";
put " FSO.DeleteFile(""&default\*.&ext""), DeleteReadOnly";
put " xlapp.Quit";
put " Set xlapp = Nothing";
put " strScript = Wscript.ScriptFullName";
put " FSO.DeleteFile(strScript)"; 
run; 
 
x "cscript ""&default\temp.vbs""";
 
%mend;
 
****************************************/
/* Create sample files to convert.      */
/****************************************/ ;
/**/
/*ods noresults;*/
/**/
/*proc sort data=sashelp.class out=test;*/
/*   by age;*/
/*run;*/
/**/
/*ods tagsets.excelxp file="D:\hengrui\test\temp.xml" newfile=bygroup;*/
/**/
/*proc print data=test;*/
/*   by age;*/
/*run;*/
/**/
/*ods tagsets.excelxp close;*/
/**/
/**/
/*options noxsync noxwait;*/
/**/
/**/
/*%convert_files(default=D:\hengrui\test,ext=xml);*/