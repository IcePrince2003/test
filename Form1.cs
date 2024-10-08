using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace BaiKiemTra
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        private string connection = "Data Source = .\\SQLEXPRESS03; Initial Catalog = BaiKiemTraSo3; Integrated Security = true";
        private SqlConnection conn;
        private SqlCommand cmd;
        private SqlDataAdapter adapter;
        private DataSet set;
        private DataTable tb;
        private int trangthai = -1;

        private void Form1_Load(object sender, EventArgs e)
        {
            conn = new SqlConnection(connection);
            conn.Open();
            setControl(true);
            loadData();
        }
        private void setControl(bool edit)
        {
            btn_add.Enabled = edit;
            btn_edit.Enabled = edit;
            btn_save.Enabled = !edit;
            txt_ten.Enabled = !edit;
        }
        private void loadData()
        {
            string display = "SELECT * FROM Kho";
            adapter = new SqlDataAdapter(display, conn);
            set = new DataSet();
            adapter.Fill(set, "Kho");
            tb = set.Tables["Kho"];
            dgv_kho.DataSource = tb;
        }
        private void changeData(string sql_query)
        {
            cmd = new SqlCommand(sql_query, conn);
            cmd.ExecuteNonQuery(); 
            loadData();
            txt_ten.Text = txt_ma.Text = string.Empty;
            setControl(true);
        }

        private void btn_add_Click(object sender, EventArgs e)
        {
            trangthai = 0;
            setControl(false);
        }

        private void btn_edit_Click(object sender, EventArgs e)
        {
            trangthai = 1;
            setControl(false);
        }

        private void btn_delete_Click(object sender, EventArgs e)
        {
            if(txt_ma.Text != string.Empty)
            {
                changeData("DELETE FROM Kho WHERE MaKho = " + txt_ma.Text);
            }    
        }

        private void btn_save_Click(object sender, EventArgs e)
        {
            if (txt_ten.Text != string.Empty)
            {
                if (trangthai == 0) changeData("INSERT Kho (TenKho) VALUES (N'" + txt_ten.Text + "')");
                else if (trangthai == 1)
                {
                    if (txt_ma.Text != string.Empty) changeData("UPDATE Kho SET TenKho = N'" + txt_ten.Text + "' WHERE MaKho = " + txt_ma.Text);
                    else MessageBox.Show("Kho không tồn tại");
                }
            }
            else MessageBox.Show("Bạn chưa nhập tên kho");
        }

        private void btn_find_Click(object sender, EventArgs e)
        {
            string find_data = "SELECT * FROM Kho WHERE MaKho = 2 ";
            if (txt_find_ma.Text != string.Empty) find_data += "AND MaKho LIKE '%" + txt_find_ma.Text + "%'";
            if (!string.IsNullOrWhiteSpace(txt_find_ten.Text)) find_data += " AND TenKho LIKE N'%" + txt_find_ten.Text + "%'";
            adapter = new SqlDataAdapter(find_data, conn);
            set = new DataSet();
            adapter.Fill(set, "Kho");
            tb = set.Tables["Kho"];
            dgv_kho.DataSource = tb;
        }

        private void dgv_kho_RowEnter(object sender, DataGridViewCellEventArgs e)
        {
            if(dgv_kho.Rows.Count > 0)
            {
                int i = e.RowIndex;
                txt_ma.Text = dgv_kho.Rows[i].Cells[0].Value.ToString();
                txt_ten.Text = dgv_kho.Rows[i].Cells[1].Value.ToString();
            }
        }

        private void txt_find_ma_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!Char.IsDigit(e.KeyChar) && !Char.IsControl(e.KeyChar)) e.Handled = true;
        }
    }
}
