import os
import shutil


def move_and_rename_images(input_folder):
    for root, dirs, files in os.walk(input_folder):
        for dir_name in dirs:
            image_path = os.path.join(root, dir_name, f"{dir_name}_combined.png")
            new_image_path = os.path.join(input_folder, f"{dir_name}.png")
            shutil.move(image_path, new_image_path)
            print(f"Moved and renamed: {image_path} -> {new_image_path}")

if __name__ == "__main__":
    input_folder = "./lib/assets/img/oldWords/中研院字形演變"  # Change this to the path of your input folder
    move_and_rename_images(input_folder)
    print(os.walk(input_folder))
