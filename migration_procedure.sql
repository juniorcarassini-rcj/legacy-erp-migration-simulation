CREATE PROCEDURE usp_MigrateLegacySalesToAnalytics
    @BatchSize INT = 5000,
    @DebugMode BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RowsAffected INT = 1;
    DECLARE @LogMessage NVARCHAR(500);

    PRINT '🚀 Starting Legacy ERP Data Migration Pipeline...';

    -- 1. Pre-Migration Validation: Check for orphaned records
    IF EXISTS (SELECT 1 FROM LegacySalesRaw WHERE CustomerId NOT IN (SELECT Id FROM LegacyCustomers))
    BEGIN
        PRINT '⚠️ Warning: Orphaned customer records detected in raw data. Proceeding with safety inner joins.';
    END

    -- 2. Transaction Management & Batch Processing (Performance Tuning for Production Environments)
    WHILE @RowsAffected > 0
    BEGIN
        BEGIN TRANSACTION;

        INSERT INTO AnalyticsSalesTarget (
            SalesInvoiceId,
            CustomerId,
            ProductSku,
            Quantity,
            TotalAmount,
            MigrationTimestamp
        )
        SELECT TOP (@BatchSize)
            src.InvoiceId,
            src.CustomerId,
            src.ItemSku,
            src.Qty,
            (src.Qty * src.UnitPrice) - ISNULL(src.DiscountAmount, 0),
            GETDATE()
        FROM LegacySalesRaw src
        INNER JOIN LegacyCustomers cust ON src.CustomerId = cust.Id
        WHERE src.IsProcessed = 0
        ORDER BY src.InvoiceId;

        SET @RowsAffected = @@ROWCOUNT;

        -- Update Legacy Staging Area to prevent infinite loops (Checkpointing)
        UPDATE TOP (@BatchSize) LegacySalesRaw
        SET IsProcessed = 1, ProcessedDate = GETDATE()
        WHERE IsProcessed = 0
        AND InvoiceId IN (SELECT SalesInvoiceId FROM AnalyticsSalesTarget);

        COMMIT TRANSACTION;

        -- Log progress metrics for DBA monitoring
        IF @DebugMode = 1
        BEGIN
            SET @LogMessage = '📊 Batch processed successfully. Rows migrated: ' + CAST(@RowsAffected AS NVARCHAR(10));
            RAISERROR(@LogMessage, 0, 1) WITH NOWAIT;
        END

        -- Small pause to prevent log saturation and CPU spikes in critical business hours
        WAITFOR DELAY '00:00:00.050';
    END

    PRINT '✅ Legacy ERP migration successfully completed. Target analytics database synchronized.';
END;
GO
