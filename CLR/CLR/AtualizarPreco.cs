//------------------------------------------------------------------------------
// <copyright file="CSSqlStoredProcedure.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void AtualizarPreco (String codigos, int percentual)
    {
        //codigos = "1,24,4,423,423,4,5,,,,,3,43,54"
        //para processar item por item...

        var cods = codigos.Split(new char[]{','}, StringSplitOptions.RemoveEmptyEntries);

        foreach (var item in cods)
        {
            var cod_produto = Int32.Parse(item);

            using (var c = new SqlConnection("context connection=true;"))
            {
                var cmd = "UPDATE PRODUTO SET PRECO_PRODUTO = PRECO_PRODUTO * @PERCENTUAL + PRECO_PRODUTO WHERE COD_PRODUTO = @COD_PRODUTO";

                using (var k = new SqlCommand(cmd, c))
                {
                    k.Parameters.AddWithValue("@PERCENTUAL", percentual / 100.0);
                    k.Parameters.AddWithValue("@COD_PRODUTO", cod_produto);

                    SqlContext.Pipe.Send(String.Format("atualizando o produto {0}", cod_produto));

                    c.Open();

                    k.ExecuteNonQuery();

                    c.Close();
                }
            }
        }
    }
}
