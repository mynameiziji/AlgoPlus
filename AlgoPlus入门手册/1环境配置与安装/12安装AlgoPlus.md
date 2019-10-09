# 好交易不求甚解安装法
* pip install 命令安装：

        pip install AlgoPlus

* easy_install命令安装：

        easy_install AlgoPlus

# 安装Visual Studio 2019

微软官网地址：[https://visualstudio.microsoft.com/zh-hans/downloads/](https://visualstudio.microsoft.com/zh-hans/downloads/)

6.65GB！如果对VS没有其他需求，建议选择在线安装。

# 下载AlgoPlus

* 码云（推荐）： [https://gitee.com/AlgoPlus/AlgoPlus](https://gitee.com/AlgoPlus/AlgoPlus)

* GitHub（慢）：[https://github.com/CTPPlus/AlgoPlus](https://github.com/CTPPlus/AlgoPlus)

# Windows安装

- 解压AlgoPlus
- 运行\tools\install_ctp.bat

    如果你看到了:
    
        Traceback (most recent call last):
          File "setup.py", line 7, in <module>
            from Cython.Build import cythonize, build_ext
        ModuleNotFoundError: No module named 'Cython'
        Traceback (most recent call last):
          File "setup.py", line 7, in <module>
            from Cython.Build import cythonize, build_ext
        ModuleNotFoundError: No module named 'Cython'
    
    我好像也发现了什么。好吧，请执行以下代码安装Cython后，再次运行安装脚本：
    
        conda install Cython

    当你看到：

        Processing dependencies for AlgoPlus==1.5
        Finished processing dependencies for AlgoPlus==1.5
        请按任意键继续. . .

    恭喜你！你已成为我们的一员了！让我们一起将交易进行到底！

    如果幸运女神再次眷顾了你，给我们再次深入交流的机会，那还等什么，房间都开好了[http://www.ctp.plus](http://www.ctp.plus)。