import argparse
import resource
import time
import numpy as np

x = 1000
y = 1000000

def high_locality_access(size=x, iterations=y):
    array = np.zeros(size, dtype=np.int32)
    sum_val = 0

    for _ in range(iterations):
        for j in range(size):
            array[j] += 1
            sum_val += array[j]
    
    return sum_val

def low_locality_access(size=y, iterations=x):
    array = np.zeros(size, dtype=np.int32)
    sum_val = 0

    np.random.seed(1)  # For reproducibility
    random_indices = np.random.randint(0, size, iterations)
    
    # Access array elements randomly
    for i in random_indices:
        array[i] += 1
        sum_val += array[i]
    
    return sum_val

def measure_page_faults(func, *args):
    # Get initial page fault counts
    major_faults_start = resource.getrusage(resource.RUSAGE_SELF).ru_majflt
    minor_faults_start = resource.getrusage(resource.RUSAGE_SELF).ru_minflt
    
    # Time the function execution
    start_time = time.time()
    result = func(*args)
    execution_time = time.time() - start_time
    
    # Get final page fault counts
    major_faults_end = resource.getrusage(resource.RUSAGE_SELF).ru_majflt
    minor_faults_end = resource.getrusage(resource.RUSAGE_SELF).ru_minflt
    
    # Calculate differences
    major_faults = major_faults_end - major_faults_start
    minor_faults = minor_faults_end - minor_faults_start
    
    return major_faults, minor_faults, execution_time

def main():
    parser = argparse.ArgumentParser(description='Memory Locality Pattern Analysis')
    parser.add_argument('--small-size', type=int, default=1000,
                      help='Size of array for high locality access')
    parser.add_argument('--large-size', type=int, default=1000000,
                      help='Size of array for low locality access')
    parser.add_argument('--iterations', type=int, default=1000000,
                      help='Number of iterations for access patterns')
    
    args = parser.parse_args()
    
    # Run and measure high locality pattern
    print("\nRunning high locality pattern test...")
    major_h, minor_h, time_h = measure_page_faults(
        high_locality_access, args.small_size, args.iterations
    )
    
    # Run and measure low locality pattern
    print("Running low locality pattern test...")
    major_l, minor_l, time_l = measure_page_faults(
        low_locality_access, args.large_size, args.iterations // 1000
    )
    
    # Print results
    print("\nResults:")
    print("\nHigh Locality Pattern:")
    print(f"Array Size: {args.small_size}")
    print(f"Major Page Faults: {major_h}")
    print(f"Minor Page Faults: {minor_h}")
    print(f"Execution Time: {time_h:.2f} seconds")
    
    print("\nLow Locality Pattern:")
    print(f"Array Size: {args.large_size}")
    print(f"Major Page Faults: {major_l}")
    print(f"Minor Page Faults: {minor_l}")
    print(f"Execution Time: {time_l:.2f} seconds")
    
    # Print system page size
    print(f"\nSystem Page Size: {resource.getpagesize()} bytes")

if __name__ == "__main__":
    main()
