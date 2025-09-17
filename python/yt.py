import yt_dlp
import tkinter as tk
from tkinter import ttk
import threading
import os

def progress_hook(d):
    if d['status'] == 'downloading':
        total = d.get("total_bytes") or d.get("total_bytes_estimate") or 1
        downloaded = d.get("downloaded_bytes", 0)
        percent = downloaded / total * 100
        progress_var.set(percent)
        label_var.set(f"Downloading: {d.get('_percent_str')} | {d.get('speed_str', '0 B/s')} | ETA: {d.get('eta_str', '?')}")
        root.update_idletasks()
    elif d['status'] == 'finished':
        label_var.set("✅ Download selesai!")
        progress_var.set(100)

def download_video(url, mode, fmt):
    if mode == "audio":
        download_path = os.path.expanduser("~/Music/Downloads")
        os.makedirs(download_path, exist_ok=True)

        ydl_opts = {
            "format": "bestaudio/best",
            "postprocessors": [{
                "key": "FFmpegExtractAudio",
                "preferredcodec": fmt,
                "preferredquality": "192",
            }],
            "progress_hooks": [progress_hook],
            "outtmpl": f"{download_path}/%(title)s_%(height)sp.%(ext)s",
            "noprogress": True,
        }
    else:  # video
        download_path = os.path.expanduser("~/Videos/Downloads")
        os.makedirs(download_path, exist_ok=True)

        ydl_opts = {
            "format": fmt,
            "progress_hooks": [progress_hook],
            "outtmpl": f"{download_path}/%(title)s.%(ext)s",
            "noprogress": True,
        }
        # tentuin output format
        if "webm" in fmt:
            ydl_opts["merge_output_format"] = "webm"
        else:
            ydl_opts["merge_output_format"] = "mp4"

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])

def start_download():
    url = entry.get()
    choice = choice_var.get()
    if choice.startswith("audio:"):
        mode, codec = choice.split(":")
    else:
        mode, codec = "video", choice
    threading.Thread(target=download_video, args=(url, mode, codec), daemon=True).start()

# === GUI ===
root = tk.Tk()
root.title("YouTube Downloader")

entry = tk.Entry(root, width=40)
entry.pack(pady=10)

menu_button = tk.Menubutton(root, text="Pilih Format", relief="raised")
menu_button.menu = tk.Menu(menu_button, tearoff=0)
menu_button["menu"] = menu_button.menu

choice_var = tk.StringVar(value="video:bestvideo[height<=720]+bestaudio")

# submenu Music
music_menu = tk.Menu(menu_button.menu, tearoff=0)
music_menu.add_radiobutton(label="MP3", variable=choice_var, value="audio:mp3")
music_menu.add_radiobutton(label="FLAC", variable=choice_var, value="audio:flac")
music_menu.add_radiobutton(label="WAV", variable=choice_var, value="audio:wav")

# submenu Video
video_menu = tk.Menu(menu_button.menu, tearoff=0)
video_menu.add_radiobutton(label="240p", variable=choice_var, value="bestvideo[height<=240]+bestaudio")
video_menu.add_radiobutton(label="360p", variable=choice_var, value="bestvideo[height<=360]+bestaudio")
video_menu.add_radiobutton(label="480p", variable=choice_var, value="bestvideo[height<=480]+bestaudio")
video_menu.add_radiobutton(label="720p", variable=choice_var, value="bestvideo[height<=720]+bestaudio")
video_menu.add_radiobutton(label="1080p", variable=choice_var, value="bestvideo[height<=1080]+bestaudio")
video_menu.add_radiobutton(label="WebM (original)", variable=choice_var, value="bestvideo[ext=webm]+bestaudio[ext=webm]")

menu_button.menu.add_cascade(label="Music", menu=music_menu)
menu_button.menu.add_cascade(label="Video", menu=video_menu)
menu_button.pack(pady=5)

btn = tk.Button(root, text="Download", command=start_download)
btn.pack(pady=5)

label_var = tk.StringVar(value="Siap download...")
label = tk.Label(root, textvariable=label_var)
label.pack()

progress_var = tk.DoubleVar()
progress = ttk.Progressbar(root, length=300, variable=progress_var, maximum=100)
progress.pack(pady=10)

root.mainloop()
