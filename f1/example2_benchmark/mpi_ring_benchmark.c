#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>
#include <fcntl.h>

// --- CPU Intensive Test: Local Matrix Multiplication ---
void run_cpu_compute_test(int rank, int size) {
    int N = 800; // 矩陣大小
    double *A = (double*)malloc(N * N * sizeof(double));
    double *B = (double*)malloc(N * N * sizeof(double));
    double *C = (double*)malloc(N * N * sizeof(double));

    for (int i = 0; i < N * N; i++) { A[i] = 1.0; B[i] = 2.0; }

    if (rank == 0) printf("--- CPU Parallel Compute Test (Matrix 800x800) ---\n");
    
    MPI_Barrier(MPI_COMM_WORLD);
    double start_t = MPI_Wtime();

    // 簡單的矩陣相乘 (三層迴圈，測試 CPU 壓力)
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            double sum = 0;
            for (int k = 0; k < N; k++) {
                sum += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] = sum;
        }
    }

    // 模擬全域同步 (Allreduce)
    double local_sum = C[0], global_sum;
    MPI_Allreduce(&local_sum, &global_sum, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);

    double end_t = MPI_Wtime();
    double total_t = end_t - start_t;

    // 取得所有 Rank 的最大時間 (代表整體執行速度)
    double max_t;
    MPI_Reduce(&total_t, &max_t, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("  Total Compute & Sync Time: %.6f seconds\n", max_t);
        printf("  Effective GFLOPS (approx): %.3f\n", (2.0 * N * N * N * size) / (max_t * 1e9));
        printf("----------------------------------------------------\n");
    }

    free(A); free(B); free(C);
}

void run_disk_io_test(int rank, const char* path_label, const char* base_path) {
    if (rank != 0) return;
    char filename[512];
    snprintf(filename, sizeof(filename), "%s/test_io_rank%d.tmp", base_path, rank);
    long io_size_bytes = 512L * 1024 * 1024; 
    char *buf = (char*)malloc(io_size_bytes);
    memset(buf, 'A', io_size_bytes);

    printf("--- Disk I/O Test: %s [%s] ---\n", path_label, base_path);
    double start_w = MPI_Wtime();
    int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd >= 0) {
        write(fd, buf, io_size_bytes);
        fsync(fd);
        close(fd);
    }
    double end_w = MPI_Wtime();
    double write_bw = (double)io_size_bytes / (1024.0 * 1024.0) / (end_w - start_w);
    printf("  Write Speed: %.2f MB/s (Time: %.3f s)\n", write_bw, end_w - start_w);

    double start_r = MPI_Wtime();
    fd = open(filename, O_RDONLY);
    if (fd >= 0) {
        read(fd, buf, io_size_bytes);
        close(fd);
    }
    double end_r = MPI_Wtime();
    double read_bw = (double)io_size_bytes / (1024.0 * 1024.0) / (end_r - start_r);
    printf("  Read Speed : %.2f MB/s (Time: %.3f s)\n", read_bw, end_r - start_r);

    unlink(filename);
    free(buf);
    printf("----------------------------------------------------\n");
}

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    char hostname[256];
    gethostname(hostname, 256);
    if (rank == 0) {
        printf("====================================================\n");
        printf(" HPC Performance Evaluation Benchmark \n");
        printf(" Total MPI Ranks: %d \n", size);
        printf("====================================================\n\n");
    }

    // 1. CPU Compute Test
    run_cpu_compute_test(rank, size);

    // 2. Network Benchmark (Ring)
    long msg_size_bytes = 10 * 1024 * 1024; 
    int iters = 50; 
    char *send_buf = (char*)malloc(msg_size_bytes);
    char *recv_buf = (char*)malloc(msg_size_bytes);
    int next = (rank + 1) % size;
    int prev = (rank - 1 + size) % size;

    MPI_Barrier(MPI_COMM_WORLD);
    double start_net = MPI_Wtime();
    for (int i = 0; i < iters; i++) {
        MPI_Sendrecv(send_buf, msg_size_bytes, MPI_CHAR, next, 0,
                     recv_buf, msg_size_bytes, MPI_CHAR, prev, 0,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }
    MPI_Barrier(MPI_COMM_WORLD);
    double end_net = MPI_Wtime();

    if (rank == 0) {
        double total_data_gb = (double)msg_size_bytes * iters * size / (1024.0 * 1024.0 * 1024.0);
        printf("--- MPI Network Ring Test ---\n");
        printf("  Total Data: %.3f GB, Time: %.6f s\n", total_data_gb, end_net - start_net);
        printf("  Bandwidth : %.3f GB/s\n", total_data_gb / (end_net - start_net));
        printf("----------------------------------------------------\n\n");
    }
    free(send_buf); free(recv_buf);

    // 3. Disk I/O Benchmark
    char *user = getenv("USER");
    char home_path[256], work1_path[256], current_path[256], tmp_path[256];
    snprintf(home_path, sizeof(home_path), "/home/%s", user);
    snprintf(work1_path, sizeof(work1_path), "/work1/%s", user);
    getcwd(current_path, sizeof(current_path));
    snprintf(tmp_path, sizeof(tmp_path), "/tmp");

    MPI_Barrier(MPI_COMM_WORLD);
    run_disk_io_test(rank, "HOME Storage", home_path);
    run_disk_io_test(rank, "WORK1 Storage", work1_path);
    run_disk_io_test(rank, "LOCAL /tmp", tmp_path);

    MPI_Finalize();
    return 0;
}
