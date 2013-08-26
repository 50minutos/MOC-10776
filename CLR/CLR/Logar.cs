//------------------------------------------------------------------------------
// <copyright file="CSSqlTrigger.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------
using System;
using System.Data;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;

public partial class Triggers
{        
    [Microsoft.SqlServer.Server.SqlTrigger (Name="UTR_PRODUTO_LOGAR", Target="PRODUTO", Event="FOR DELETE")]
    public static void Logar ()
    {
	    SqlContext.Pipe.Send("PASSEI NA TRIGGER!!!");
    }
}
