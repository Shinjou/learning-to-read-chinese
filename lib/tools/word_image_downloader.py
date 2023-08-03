import requests
import time 
fonts = ['甲骨文', '金文', '楚系文字', '小篆']
def download_png_files(base_url, words):
    for word in words:
        for font in fonts:
            url = base_url.format( word = word, font = font )

            response = requests.get(url)
            
            if response.status_code == 200:
                with open('D:/github/learning-to-read-chinese/lib/assets/oldWords/'+word+'.png', 'wb') as file:
                    file.write(response.content)
                    print(f'Downloaded {word}.png successfully.')
                    break
            else:
                print(response)
                # print(f'Failed to download {word}.png.')
            
            time.sleep(1.0)

if __name__ == '__main__':
    base_url = "https://char.iis.sinica.edu.tw/TTF/getTTF1.aspx?word={word}&f={font}&s=100&c=black"
    words = ['小','羊','草','吃','天','少','高','開','心','出','門','去']
    download_png_files(base_url, words)
