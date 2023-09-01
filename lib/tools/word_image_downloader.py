import requests
import time 
import os
fonts = ['甲骨文', '金文', '楚系文字', '小篆']
def download_png_files(base_url, words):
    for word in words:
        for font in fonts:
            url = base_url.format(word = word, font = font)
            
            folder = os.path.join('D:/github/learning-to-read-chinese/lib/assets/oldWords/', word)
            if(not os.path.exists(folder)):
                os.makedirs(folder)
            
            response = requests.get(url, headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"})
            
            if response.status_code == 200:
                with open((folder+f"/{word}_{font}.png"), 'wb') as file:
                    file.write(response.content)
                    print(f'Downloaded {word}_{font}.png successfully.')
            else:
                print(response)
            
            time.sleep(0.1)

if __name__ == '__main__':
    base_url = "https://char.iis.sinica.edu.tw/TTF/getTTF1.aspx?word={word}&f={font}&s=100&c=black"
    words = ['小','羊','草','吃','天','少','高','開','心','出','門','去']
    download_png_files(base_url, words)
