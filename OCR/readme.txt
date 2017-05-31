说明：
1）扩展名是doc的文件，为接口文档
2）扩展名是jar的，为demo所需要的jar包，复制到tomcat的对应的lib文件夹里，比如tomcat\webapps\ROOT\WEB-INF\lib
3）扩展名是jsp的，为jsp形式的demo程序，需要复制到tomcat对应文件夹里，比如可以是tomcat\webapps\ROOT\demo
4）test_doc.jpg为测试文档识别的图片，复制到d盘根目录下即可
5）测试：启动tomcat（tomcat需要自己搭建好，假定端口号为8080），打开浏览器，输入http://localhost:8080/demo/demo.jsp
回车后，显示对test_doc.jpg识别后的结果，也可通过查看网页的源代码查看