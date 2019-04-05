一、初始化
1 安装git tortoisegit以及语言包
2 生成秘钥：ssh-keygen -t rsa -C  ".hrglobe.com" 并且发给xin
3 添加远程库 
Git remote add origin git@git.coding.net:xinwei_/project_.git
4 举例生成项目 shr_xxxx;
A: clone 标准程序到文件夹 shr_xxxx
Git clone git@git.coding.net:xinwei_/project_.git D:/HR_PROJECTS/shr_xxxx
B: 转到shr_xxxx文件夹下，建立并且切换到shr_xxxx分支
Git checkout -b shr_xxxx
C:在shr_xxxx/pgm/下面新建一个程序 test.sas;
D:添加test.sas 到版本库中 
Git add pgm/test.sas
E:提交数据 并且添加说明
Git commit -m ‘add new file test.sas’
F:推送分支到远程
Git push origin shr_xxxx

二、更新本地项目分支远程master分支的最新内容
   1、进入自己本地项目分支文件夹
   2、git remote -v （显示远程库有哪些，找到确定该库，将来可能有多个库）
   3、取得远程库master分支到tmp分支（取得远程分支到自己本地的master也行后面就用本地的master和项目分支合并就好了，后面就不用删除master）
	 git fetch origin master:tmp
   4、比较本地项目分支与远程分支的不同
	 git diff tmp
   5 确定比较结果可以合并，将远程库master与本地项目分支合并
	 git merge tmp
   6 删除tmp
	 Git branch -d tmp
   7 push 到远端项目分支
   
 三、关于版本库中.gitignore文件设置问题
   1.“.gitignore”文件的作用：在我们进行项目的时候，有很多自己的本地文件是不需要push到远端分支，这个时候可以通过设置“.gitignore”文件来进行过滤
   2.1配置语法：
	  1）以斜杠“/”开头表示目录；（常用）
      2）以星号“*”通配多个字符；（常用）
      3）以问号“?”通配单个字符
      4）以方括号“[]”包含单个字符的匹配列表；
      5）以叹号“!”表示不忽略(跟踪)匹配到的文件或目录；（常用）
   2.2常用规则：
      1）/data/*               过滤整个data文件夹里的内容   
      2）*.zip                 过滤所有zip文件
      3）/data/one.txt         过滤某个具体文件
	  在前面加上"!"时，则为保留满足条件的文件，eg. 1）!*.zip          保留所有zip文件
                                                   2）!/data/one.txt  保留某个具体文件
   2.3组合使用：
       /data/*
       !/data/one.txt     这两个语句表示：只需要管理/data/目录中的one.txt文件，其他文件都不需要管理
   3.我们project_版本库中的忽略规则：
      例： /output/*
          !/output/null          保留output文件夹中null文件，其他文件均不需要管理
     注：其他的设置可以根据以上的语法与规则解读及联系
	 
四、多人协作完成同一个项目的步骤
    1.建立或clone一个新的分支
	  1）项目的主导者需要在远程建立一个新分支：Git clone git@git.coding.net:xinwei_/project_.git D:/HR_PROJECTS/hr_项目名      /*clone标准库到指定文件夹*/
                                                   ↓
                                               Git checkout -b <shr_分支名,与项目名称相同>         /*进入新建的文件夹中，创建本地分支*/
                                                   ↓ 
                                               Git push origin <shr_分支名 >       /*push分支，第一次push会在远端建立新的分支*/
      2）项目合作者可直接clone主导者已经建立好的分支：git clone -b <branch name> [remote repository address] <local path>
	                                                  /*  例如   git clone -b hr_项目名  git@git.coding.net:xinwei_/project_.git D:/HR_PROJECTS/hr_项目名   */
	2.多人协作中的主体步骤：从add到push的过程，以及出现冲突时如何解决
	    在本地分支中工作后，先将自己的变动进行 Git add → Git commit ，在push之前需要先fetch远端的分支，来与本地的分支进行比较与合并
	                                           Git fetch origin <shr_分支名 >: tmp    /*fetch到tmp分支，tmp为临时建立的分支*/ 
											       ↓
											   Git diff tmp    /*比较tmp分支与当前分支的不同,之后通过“Q”键退出*/
											       ↓
											   Git merge tmp     /*合并tmp分支与当前分支*/
											       ↓
											   Git status       /*如果远端分支与本地分支未对同一个文件进行修改，可以直接merge成功，但如果存在同时修改的情况，便会出现冲突，
											                       可用此语句查看是哪个文件出现了冲突，打开冲突的文件，可以查看哪些内容不同，可进行手动修改与远端保持一致*/
											       ↓
											   Git add → Git commit→ Git branch -d tmp → Git push origin <shr_分支名 >  /*修改后重新add，commit，删除临时分支tmp，然后push*/
	3.项目结束后，主导者可通过此语句删除远端分支，避免远端分支冗余：
	                                           git push origin --delete <远端分支>  
      






	  