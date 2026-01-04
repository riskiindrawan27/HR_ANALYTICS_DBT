with src as (
    select * from {{ ref('daftar_pegawai') }}
),

clean as (
    select
        trim(cast(NIK_KARYAWAN as varchar)) as nik_karyawan,
        trim(cast(PERUSAHAAN as varchar))   as perusahaan,
        try_cast(HIRE_DATE as date)         as hire_date,
        try_cast(TERMINATION_DATE as date)  as termination_date,

        upper(trim(cast(STATUS as varchar))) as status
    from src
)

select *
from clean
where hire_date is not null

