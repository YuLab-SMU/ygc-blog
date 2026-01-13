import os
import sys
import time
import json
import base64
import urllib.request
import requests
import argparse
from datetime import datetime
from volcenginesdkcore.signv4 import SignerV4

def generate_image_jimeng(prompt, width=1024, height=1024, model_version="jimeng_t2i_v40"):
    """
    使用即梦 API (HighAesGeneralV20) 生成图片
    """
    # 1. 配置鉴权信息
    ak = os.environ.get("VOLCENGINE_AK")
    sk = os.environ.get("VOLCENGINE_SK")
    
    if not ak or not sk:
        raise ValueError("请确保环境变量 VOLCENGINE_AK 和 VOLCENGINE_SK 已设置")

    # 清理潜在的引号
    ak = ak.replace('"', '').replace("'", '').strip()
    sk = sk.replace('"', '').replace("'", '').strip()
    
    # 2. API 配置
    service = "cv"
    version = "2022-08-31"
    region = "cn-north-1"
    host = "visual.volcengineapi.com"
    protocol = "https"
    
    # 构造请求体
    body = {
        "req_key": model_version,
        "prompt": prompt,
        "width": width,
        "height": height,
    }
    
    query = {
        "Action": "HighAesGeneralV20",
        "Version": version
    }
    
    try:
        print(f"🚀 正在请求即梦 AI 生成图片: {prompt}")
        
        url = f"{protocol}://{host}/"
        r = requests.Request('POST', url, params=query, json=body)
        prepped = r.prepare()
        
        # 签名
        headers = prepped.headers
        headers["Host"] = host
        SignerV4.sign(
            path="/", method="POST", headers=headers, body=json.dumps(body),
            post_params=None, query=query, ak=ak, sk=sk, region=region, service=service
        )
        
        # 发送请求
        s = requests.Session()
        resp = s.send(prepped)
        
        if resp.status_code != 200:
            print(f"❌ API 请求失败: {resp.status_code}")
            print(resp.text)
            return []
            
        resp_json = resp.json()
        
        # 解析结果
        if "data" in resp_json:
             data = resp_json["data"]
             if data.get("status") in ["success", "done"] or data.get("binary_data_base64"):
                 print("✅ 图片生成成功！")
                 if data.get("image_urls"):
                     return data.get("image_urls", [])
                 elif data.get("binary_data_base64"):
                     return [f"data:image/jpeg;base64,{b64}" for b64 in data["binary_data_base64"]]
        
        print("❌ 未获取到图片链接")
        print(resp_json)
        return []

    except Exception as e:
        print(f"❌ 发生未知错误: {e}")
        return []

def download_image(url, save_dir="."):
    try:
        if not os.path.exists(save_dir):
            os.makedirs(save_dir)
            
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"jimeng_{timestamp}_{int(time.time() % 1000)}.jpg"
        filepath = os.path.join(save_dir, filename)
        
        print(f"⬇️ 正在下载图片到: {filepath}")
        
        if url.startswith("data:image/"):
            header, encoded = url.split(",", 1)
            data = base64.b64decode(encoded)
            with open(filepath, "wb") as f:
                f.write(data)
        else:
            urllib.request.urlretrieve(url, filepath)
            
        print("✨ 图片下载完成！")
        return filepath
    except Exception as e:
        print(f"❌ 下载失败: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Jimeng AI Image Generator")
    parser.add_argument("--prompt", required=True, help="Prompt for image generation")
    parser.add_argument("--ratio", default="1:1", help="Aspect ratio (1:1, 16:9, 9:16, 4:3, 3:4)")
    parser.add_argument("--output_dir", default=".", help="Directory to save images")
    
    args = parser.parse_args()
    
    # Ratio mapping (approximate for typical model support)
    ratios = {
        "1:1": (1024, 1024),
        "16:9": (1792, 1024),
        "9:16": (1024, 1792),
        "4:3": (1408, 1056), 
        "3:4": (1056, 1408),
    }
    
    width, height = ratios.get(args.ratio, (1024, 1024))
    
    # Ensure output dir exists
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)
        
    print(f"Generating image with prompt: {args.prompt}")
    print(f"Size: {width}x{height} (Ratio: {args.ratio})")
    print(f"Output directory: {args.output_dir}")
    
    image_urls = generate_image_jimeng(args.prompt, width=width, height=height)
    
    if image_urls:
        for url in image_urls:
            download_image(url, save_dir=args.output_dir)
    else:
        print("Failed to generate image.")

if __name__ == "__main__":
    main()
