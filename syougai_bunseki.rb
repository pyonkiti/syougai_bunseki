class SyougaiBunseki
    class << self

        require 'natto'

        # メイン処理
        def proc_main(flg)
            case flg
                when :add
                    # インプットファイルの一覧
                    input_file_arry = ["1.txt", "2.txt", "3.txt"]
                    file_txt = []

                    input_file_arry.each do |file|
                        # インプットファイルの読み込み
                        ret, msg, txt = SyougaiBunseki.read_input(file)
                        if ret != true
                            puts "#{msg}"
                            return false
                        else
                            file_txt << txt
                        end
                    end

                    # アウトプットファイルの削除
                    ret = SyougaiBunseki.check_file
                    return false if ret != true

                    # 形態素解析で名詞だけを抽出
                    ret = SyougaiBunseki.write_output(file_txt.flatten!.join(","))
                    return false if ret != true

                when :red
                else
                    puts "引数の指定に誤りがあります。"
                    return false
            end

            if [:add, :red].include?(flg)
                # 形態素解析で名詞だけを抽出
                ret, txt = SyougaiBunseki.calc_mecab
                return false if ret != true
            end

            return true
        end

        # インプットファイルの読み込み
        def read_input(file)
            
            if File.exist?(file) != true
                return false, "fileが存在しません", nil
            end

            begin
                txt = []
                file = File.open(file, "r")
                txt << file.read.to_s
                file.close
                return true, nil, txt

            rescue => ex
                err = self.name.to_s + "." + __method__.to_s + " : " + ex.message
                puts err
                return false, nil
            end
        end

        # アウトプットファイルの削除
        def check_file
            
            begin
                fil = File.open("output.txt","a")
                fil.close
                File.delete("output.txt")
                return true

            rescue => ex
                err = self.name.to_s + "." + __method__.to_s + " : " + ex.message
                puts err
                return false
            end
        end
       
        # 形態素解析で名詞だけを抽出
        # メモ：84653件 （本番データ）
        def write_output(txt)
            
            begin
                fil = File.open("output.txt","a")
                idx = 0

                natto = Natto::MeCab.new
                natto.parse(txt) do |n|
                    
                    fil.puts("#{n.surface}") if n.feature.to_s.chomp.split(",")[0] == "名詞"
                    
                    puts "#{idx.to_s.rjust(5)}件 - 処理中" if (idx.divmod(1000)[1] == 0 and idx != 0)
                    # break if idx >= 50000
                    idx += 1
                end
                fil.close
                puts "#{idx.to_s.rjust(5)}件 - 完　了"
                return true
                
            rescue => ex
                err = self.name.to_s + "." + __method__.to_s + " : " + ex.message
                puts err
                return false
            end
        end
        
        # 分析結果の表示
        def calc_mecab
            
            arry = []
            begin
                File.open("output.txt","r") do |f|
                    f.each { arry << f.gets.to_s.chomp }
                end

                # 配列→ハッシュに変換
                hash = arry.group_by(&:itself).map{ |key, val| [key, val.count] }.to_h

                # キーでソート
                hash = hash.sort_by { |key, val| val }.reverse.to_h

                # マッチングが多いキーのみ絞り込み
                hash.select! { |key, val| val >= 30 }
                
                # ゴミデータを控除
                excluded_keys = [["\"","\",\"","/",":","-","(",",",".","\",\"\"","_","\\",")"],
                                 ["こと","時","日","ため","月","よう","さん","100","分","年","の","１","２","為","中","ところ"],
                                 [*"2000".. "2024"],
                                 [*"0".."22"],
                                 [*"00".."30"]]
                excluded_keys.each do |excluded_keys|
                    hash.reject! { |key, val| excluded_keys.include?(key) }
                end

                # 結果表示
                hash.each { |key, val| puts "#{val.to_s.rjust(3)} 件 #{key}" }
                    
                return true, hash

            rescue => ex
                err = self.name.to_s + "." + __method__.to_s + " : " + ex.message
                puts err
                return false, nil
            end
        end
    end
end

# メイン処理
# 引数：all 全ての処理を流す :red アウトプットファイルの読み込みのみ実行
ret = SyougaiBunseki.proc_main(:red)
if ret != true
    puts "処理が中断しました。"
    exit
end

puts "処理が完了しました"
exit
