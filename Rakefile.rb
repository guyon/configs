# Config Build Rakefile

require "find"
require 'rake/packagetask'

# 定数値
VERSION = Time.now.strftime("%Y%m%d%H%M%S").to_s
HOME = File.expand_path("~")
EXCLUDE_FILES = /pkg\/|\.git\/|\.DS_Store|\.swp$|\.swo$|\.back$|Rakefile.rb$/
GIT_REPO = "git@guyon.unfuddle.com:guyon/configs.git"
unless HOME
    p "Not found home direcotry. Please set home envroiment varibale."
    exit
end

task :default    => ["update"]
task :rep_build  => ["rep_download","update","rep_remove"]
task :rep_update => ["rep_download","update"]

# ホームディレクトリのupdate最新にする
task "update" do
    src_path = File.expand_path("./")
    dst_path = File.expand_path(HOME)

    # --配布
    file_copy src_path, dst_path

    # --削除
    # リポジトリ直下のディレクトリのみ削除対象とする
    Dir.foreach(src_path) {|file|
        if File.ftype(file) == "directory" && file.to_str !~ /^\.$|^\.\.$/
            remove_src_path = src_path + "/" + file.to_str
            remove_dst_path = dst_path + "/" + file.to_str
            file_remove remove_src_path, remove_dst_path
        end
    }
    p "Update Finish."
end

def file_copy(src_path,dst_path)
    Find.find(src_path){|src_file|
        # デプロイしないファイル
        next if src_file.to_str =~ EXCLUDE_FILES
        if File.file?(src_file)
            match = Regexp.new("^" + src_path)
            dst_file = dst_path + src_file.sub(match,"")
            if !File.exist?(dst_file)
                dir = File.dirname(dst_file)
                if !File.exist?(dir)
                    # make directories
                    FileUtils.mkdir_p(dir)
                end
                # copy new src_file -> dst_file
                FileUtils.cp(src_file,dst_file,:preserve=>true)
                puts "copy new " + src_file + " => " + dst_file
            elsif FileUtils.cmp(src_file,dst_file)==false
                # copy rewrite src_file -> dst_file
                FileUtils.cp(src_file,dst_file,:preserve=>true)
                puts "copy wrt " + src_file + " => " + dst_file
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

task "rep_download" do
    workDir = HOME + "/configs_work/" + VERSION
    mkdir_p workDir
    cd workDir
    sh "git clone #{GIT_REPO}"
    cd "./configs"
end

task "rep_remove" do
    workDir = HOME + "/configs_work/"
    rm_rf workDir
end

Rake::PackageTask.new("configs",VERSION) do |p|
    p.package_dir = "./pkg"
    p.need_zip = true
    # リポジトリ直下のディレクトリのみ削除対象とする
    Dir.foreach("./") {|file|
        next if file.to_str =~ EXCLUDE_FILES
        if File.ftype(file) == "directory" && file.to_str !~ /^\.$|^\.\.$/
            p.package_files.include(".*")
            p.package_files.include(file.to_str + "/**/*")
            p.package_files.exclude('**/*~')
            p.package_files.exclude("pkg/**",/^\.git$/,/\.git\//,".DS_Store",/\.swp$/,/\.swo$/,/\.back$/,"Rakefile.rb")
        end
    }
end
