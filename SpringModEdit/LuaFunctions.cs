#region using

using System.Collections.Generic;
using System.Drawing;

#endregion

namespace SpringModEdit
{
    public static class LuaFunctions
    {
        #region Properties

        public static List<EchoEvent> EchoEvents = new List<EchoEvent>();

        #endregion

        #region Public methods

        public static void Echo(string s)
        {
            lock (EchoEvents) EchoEvents.Add(new EchoEvent(s));
        }

        public static void Echo(string s, string color)
        {
            var col = Color.Black;
            try {
                col = Color.FromName(color);
            } catch {}
            lock (EchoEvents) EchoEvents.Add(new EchoEvent(s, col));
        }

        #endregion

        #region Nested type: EchoEvent

        public class EchoEvent
        {
            #region Properties

            public Color color = Color.Black;
            public string message;

            #endregion

            #region Constructors

            public EchoEvent(string mes)
            {
                message = mes;
            }

            public EchoEvent(string mes, Color col)
            {
                message = mes;
                color = col;
            }

            #endregion
        }

        #endregion
    }
}