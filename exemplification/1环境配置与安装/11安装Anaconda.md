# 下载

1. 推荐Anconda3 64-bit
    * [ ] 官网： [https://www.anaconda.com/distribution/](https://www.anaconda.com/distribution/)
    * [ ] 清华镜像： [https://mirrors.tuna.tsinghua.edu.cn/anaconda/](https://www.anaconda.com/distribution/)

2. 强迫症重度患者可选择Miniconda3 64-bit
    * [ ] 官网： [https://docs.conda.io/en/latest/miniconda.html](https://docs.conda.io/en/latest/miniconda.html)
    * [ ] 清华镜像： [https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/](https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/)

# Windows安装

1. 根据提示完成安装，遇到Advanced Options时，请勾选以下选项:
    * [ ] Add Anconda to my PATH environment variable
    * [ ] Register Anconda as my default Python 3.7

2. 检查是否安装成功。在cmd中执行python命令，希望你能看到以下内容：

        Python 3.7.3 (default, Apr 24 2019, 15:29:51) [MSC v.1915 64 bit (AMD64)] :: Anaconda, Inc. on win32
        ……

    如果你看到了：

        python' 不是内部或外部命令，也不是可运行的程序或批处理文件。

    我们只能先对此表示遗憾，再对您表示同情，最后请您按照以下步骤添加环境变量：
    
    ①随便打开一个文件夹，右键单击左侧列中的【我的电脑】 \
    ②左键单击菜单中【属性】选项 \
    ③在新窗口中左键单击【高级系统设置】 \
    ④在新窗口左键单击【高级】选项卡，再左键单击【环境变量】按钮 \
    ⑤在新窗口的用户变量（或者系统变量）列表中单击【Path】条目，将【Anaconda安装目录】、【\Scripts】、【\Library\bin】三个文件夹的完整路径添加其中。
    例如我电脑里添加的环境变量（不好，似乎有什么秘密要被发现了）：
    
        C:\AlgoPlus\miniconda3
        C:\AlgoPlus\miniconda3\Scripts
        C:\AlgoPlus\miniconda3\Library\bin
        

3. 重新打开一个cmd窗口，检查是否安装成功。如果你的运气有那么一丢丢不好，请在社区（ [http://www.ctp.plus](http://www.ctp.plus) ）中发帖咨询。

# 更换清华源，享受飞一样的感觉

1. 执行以下命令换conda源

        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
        conda config --set show_channel_urls yes
  
2. 执行以下命令换pip源

        pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U
        pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 虚拟环境

当有多个开发版在同时推进的情况下，为了避免对生产环境产生影响，可以创建虚拟环境。例如，CTP穿透式刚推行时，穿透式版和非穿透式版同时运行。通过创建一个穿透式虚拟环境，就可以避免调试新版本接口对生产环境造成影响。

- 创建代号为ctp_dev（根据需要设定）的虚拟环境环境

        conda create --name ctp_dev python=3.7
  
- 列示所有环境信息，其中base是默认的主环境。

        conda env list
  
- 需要使用ctp_dev虚拟环境时，只需要使用以下代码激活之后所有操作都在虚拟环境目录（Miniconda3\envs\ctp_dev）中执行。

        conda activate ctp_dev
  
- 退出当前虚拟环境

        conda deactivate
  
- 删除代号为ctp_dev的虚拟环境

        conda remove --name ctp_dev --all`
  
# 强迫症患者必看

- 更新

        conda update conda
        conda update anaconda
        conda update --all

- 删除可写程序包缓存中未被使用的包。

        conda clean -p

- 删除缓存的tar包

        conda clean -t

- 删除索引缓存、锁定文件、未使用的缓存包和tar包

        conda clean -all

# 卸载

纳尼？你居然告要卸载？门儿都没有！窗户都封死了！和我们一起将交易进行到底！

（换副笑脸）大爷，第二课的教程也给您准备好了，一定来玩呀……