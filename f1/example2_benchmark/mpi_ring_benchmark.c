#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // 每個 Rank 發送與接收的資料大小 (10 MB)
    long msg_size_bytes = 10 * 1024 * 1024; 
    int iters = 100; // 交換次數

    char *send_buf = (char*)malloc(msg_size_bytes);
    char *recv_buf = (char*)malloc(msg_size_bytes);

    // 定義左鄰(prev)與右舍(next)構成一個環 (Ring)
    int next = (rank + 1) % size;
    int prev = (rank - 1 + size) % size;

    // 暖身 (Warm-up)
    MPI_Sendrecv(send_buf, msg_size_bytes, MPI_CHAR, next, 0,
                 recv_buf, msg_size_bytes, MPI_CHAR, prev, 0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);

    MPI_Barrier(MPI_COMM_WORLD);
    
    // 開始計時
    double start_time = MPI_Wtime();

    for (int i = 0; i < iters; i++) {
        // 同步雙向同時送跟收，測量實體頻寬
        MPI_Sendrecv(send_buf, msg_size_bytes, MPI_CHAR, next, 0,
                     recv_buf, msg_size_bytes, MPI_CHAR, prev, 0,
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    
    // 結束計時
    double end_time = MPI_Wtime();
    double total_time = end_time - start_time;

    if (rank == 0) {
        // 總傳輸量 = 單次大小(MB) * 次數 * Rank數量 / 1024 = GB
        double total_data_gb = (double)msg_size_bytes * iters * size / (1024.0 * 1024.0 * 1024.0);
        printf("====================================================\n");
        printf(" MPI Ring Communication Benchmark \n");
        printf("====================================================\n");
        printf(" Total MPI Ranks (Cores) : %d\n", size);
        printf(" Message Size per Rank   : %ld bytes (10 MB)\n", msg_size_bytes);
        printf(" Iterations              : %d\n", iters);
        printf(" Total Data Transferred  : %.3f GB\n", total_data_gb);
        printf(" Total Time Elapsed      : %.6f seconds\n", total_time);
        printf("----------------------------------------------------\n");
        printf(" => Aggregate Bandwidth  : %.3f GB/s\n", total_data_gb / total_time);
        printf("====================================================\n");
    }

    free(send_buf);
    free(recv_buf);
    MPI_Finalize();
    return 0;
}
