import boto3
import time
import os
import statistics
import csv
from concurrent.futures import ThreadPoolExecutor

# ==== Configuration ====
AWS_ENDPOINT = "http://192.168.1.1:9000"  # Your S3 server endpoint
ACCESS_KEY = "*******"
SECRET_KEY = ""*******""
BASE_BUCKET_NAME = "test1"
REGION_NAME = "us-east-1"  # Optional
NUM_FILES = 10
FILE_SIZE_MB = 5
THREADS = 4

# ==== Record start time ====
benchmark_start_time = time.strftime("%Y-%m-%d %H:%M:%S")
benchmark_start_timestamp = time.time()
print(f"Benchmark start time: {benchmark_start_time}")

# ==== Initialize S3 client ====
s3 = boto3.client(
    "s3",
    endpoint_url=AWS_ENDPOINT,
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
    region_name=REGION_NAME,
    verify=False
)

# ==== Helper functions ====
def random_bytes(size_mb):
    return os.urandom(size_mb * 1024 * 1024)

def upload_file(bucket, file_name, data):
    start = time.time()
    s3.put_object(Bucket=bucket, Key=file_name, Body=data)
    return time.time() - start

def download_file(bucket, file_name):
    start = time.time()
    s3.get_object(Bucket=bucket, Key=file_name)
    return time.time() - start

def print_latency_stats(name, times):
    times_ms = [t * 1000 for t in times]
    times_sorted = sorted(times_ms)
    print(f"\n{name} stats (ms):")
    print(f"  Min   : {min(times_sorted):.2f}")
    print(f"  Max   : {max(times_sorted):.2f}")
    print(f"  Avg   : {statistics.mean(times_sorted):.2f}")
    print(f"  Median: {statistics.median(times_sorted):.2f}")
    print(f"  p90   : {times_sorted[int(0.9*len(times_sorted))-1]:.2f}")
    print(f"  p99   : {times_sorted[int(0.99*len(times_sorted))-1]:.2f}")

# ==== Create bucket with unique name ====
timestamp = int(time.time())
BUCKET_NAME = f"{BASE_BUCKET_NAME}-{timestamp}"
try:
    s3.create_bucket(Bucket=BUCKET_NAME)
    print(f"Bucket '{BUCKET_NAME}' created.")
except s3.exceptions.BucketAlreadyOwnedByYou:
    print(f"Bucket '{BUCKET_NAME}' already exists and owned by you.")

# ==== Generate test file data ====
files_data = {f"file_{i}.bin": random_bytes(FILE_SIZE_MB) for i in range(NUM_FILES)}

# ==== Upload test ====
upload_times = []
print("\nStarting upload test...")
with ThreadPoolExecutor(max_workers=THREADS) as executor:
    futures = [executor.submit(upload_file, BUCKET_NAME, fname, data) for fname, data in files_data.items()]
    for f, fname in zip(futures, files_data.keys()):
        t = f.result()
        upload_times.append(t)
        print(f"Uploaded {fname} in {t*1000:.2f} ms")

print_latency_stats("Upload", upload_times)
print(f"Upload throughput: {FILE_SIZE_MB * NUM_FILES / sum(upload_times):.2f} MB/s")

# ==== Download test ====
download_times = []
print("\nStarting download test...")
with ThreadPoolExecutor(max_workers=THREADS) as executor:
    futures = [executor.submit(download_file, BUCKET_NAME, fname) for fname in files_data.keys()]
    for f, fname in zip(futures, files_data.keys()):
        t = f.result()
        download_times.append(t)
        print(f"Downloaded {fname} in {t*1000:.2f} ms")

print_latency_stats("Download", download_times)
print(f"Download throughput: {FILE_SIZE_MB * NUM_FILES / sum(download_times):.2f} MB/s")

# ==== Prepare report directory and filename ====
script_dir = os.path.dirname(os.path.abspath(__file__))  
parent_dir = os.path.dirname(script_dir) 
report_dir = os.path.join(parent_dir, "reports")
os.makedirs(report_dir, exist_ok=True)

timestamp_str = time.strftime("%Y%m%d_%H%M%S")
csv_report_path = os.path.join(report_dir, f"s3_latency_report_{timestamp_str}.csv")

# ==== Record end time ====
benchmark_end_time = time.strftime("%Y-%m-%d %H:%M:%S")
benchmark_end_timestamp = time.time()
total_duration = benchmark_end_timestamp - benchmark_start_timestamp
print(f"\nBenchmark end time: {benchmark_end_time}")
print(f"Total benchmark duration: {total_duration:.2f} seconds")

# ==== Save CSV report ====
with open(csv_report_path, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["File", "Upload_ms", "Download_ms"])
    for fname, u_time, d_time in zip(files_data.keys(), upload_times, download_times):
        writer.writerow([fname, round(u_time*1000, 2), round(d_time*1000, 2)])
    # Add benchmark start/end time at the end
    writer.writerow([])
    writer.writerow(["Benchmark Start", benchmark_start_time])
    writer.writerow(["Benchmark End", benchmark_end_time])
    writer.writerow(["Total Duration_s", round(total_duration, 2)])

print(f"\nLatency report saved to '{csv_report_path}'")

# ==== Cleanup bucket and objects ====
print("\nCleaning up test bucket and files...")
for key in files_data.keys():
    s3.delete_object(Bucket=BUCKET_NAME, Key=key)
s3.delete_bucket(Bucket=BUCKET_NAME)
print(f"Bucket '{BUCKET_NAME}' and all test files have been deleted.")
