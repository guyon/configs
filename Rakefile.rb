# Config Build Rakefile

require "find"
require 'rake/packagetask'

# 定数値
NOW = Time.now.strftime("%Y%m%d%H%M%S").to_s
HOME = File.expand_path("~")
WIN_RENAME = {".vimperator" => "vimperator"}
EXCLUDE_FILES = Regexp.new("pkg\/|\.git\/|\.DS_Store|\.swp$|\.swo$|\.back$|Rakefile.rb$")
GIT_REPO = "git@guyon.unfuddle.com:guyon/configs.git"
unless HOME
    p "Not found home direcotry. Please set home envroiment varibale."
    exit
end

# タスクの関連付け
task :default    => ["update","win_rename_after"]
task :rep_build  => ["rep_clone","update","win_rename_after","work_dir_remove"]
task :rep_update => ["rep_clone","update","win_rename_after"]

desc "カレントディレクトリのConfigsからHOMEディレクトリにBuildする"
task "update" => "win_rename_before"do
    src_path = File.expand_path("./")
    dst_path = File.expand_path(HOME)

    # --配布
    file_copy src_path, dst_path

    # --削除
    # リポジトリ直下のディレクトリのみ削除対象とする
    Dir.foreach(src_path) {|file|
        if File.ftype(file) == "directory" && file.to_s !~ /^\.$|^\.\.$/
            remove_src_path = src_path + "/" + file.to_s
            remove_dst_path = dst_path + "/" + file.to_s
            file_remove remove_src_path, remove_dst_path
        end
    }
    p "Update Finish."
end

desc "最新バージョンのconfigsリポジトリを作成する"
task "rep_clone" do
    work_dir = HOME + "/configs_work/" + NOW
    mkdir_p work_dir
    cd work_dir
    sh "git clone #{GIT_REPO}"
    cd "./configs"
end

desc "workディレクトリを削除する"
task "work_dir_remove" do
    remove_dir = HOME + "/configs_work/"
    rm_rf remove_dir
end

desc "Windowsの命名規約のファイルがあれば元に戻す"
task "win_rename_before" do
    return unless Rake::Win32::windows?
    WIN_RENAME.each_pair{|key,value|
       next unless File.exist?(HOME + "/" + value)
       FileUtils.mv(HOME + "/" + value, HOME + "/" + key)
    }
end

desc "Windowsの命名規約に変更する"
task "win_rename_after" do
    return unless Rake::Win32::windows?
    WIN_RENAME.each_pair{|key,value|
       #FileUtils.rm_rf(HOME + "/" + value)
       FileUtils.mv(HOME + "/" + key, HOME + "/" + value)
    }
end

Rake::PackageTask.new("configs",NOW) do |p|
    p.package_dir = HOME + "/configs_work/pkg/"
    p.need_zip = true
    # リポジトリ直下のディレクトリのみ削除対象とする
    Dir.foreach("./") {|file|
        next if file.to_s =~ EXCLUDE_FILES
        if File.ftype(file) == "directory" && file.to_s !~ /^\.$|^\.\.$/
            p.package_files.include(".*")
            p.package_files.include(file.to_s + "/**/*")
            p.package_files.exclude('**/*~')
            #TODO:パターンを定数値化する
            p.package_files.exclude("pkg/**",/^\.git$/,/\.git\//,".DS_Store",/\.swp$/,/\.swo$/,/\.back$/,"Rakefile.rb")
        end
    }
end

def file_copy(src_path,dst_path)
    Find.find(src_path){|src_file|
        next if src_file.to_s =~ EXCLUDE_FILES
        if File.file?(src_file)
            match = Regexp.new("^" + src_path)
            dst_file = dst_path + src_file.sub(match,"")
            if !File.exist?(dst_file)
                dir = File.dirname(dst_file)
                if !File.exist?(dir)
                    FileUtils.mkdir_p(dir)
                end
                FileUtils.cp(src_file,dst_file,:preserve=>true)
                puts "copy new " + src_file + " => " + dst_file
            elsif FileUtils.cmp(src_file,dst_file)==false
                FileUtils.cp(src_file,dst_file,:preserve=>true)
                puts "copy rewrite " + src_file + " => " + dst_file
            end
        end
    }
end

def file_remove(src_path,dst_path)
    return unless File.exist?(dst_path)
    Find.find(dst_path){|dst_file|
        match = Regexp.new("^" + dst_path)
        src_file = src_path + dst_file.sub(match,"")
        if !File.exist?(src_file)
            FileUtils.rm_rf(dst_file)
            puts "remove " + dst_file
        end
    }
end
