using Godot;
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public partial class HookScript : Node
{
	private const int WH_MOUSE_LL = 14;
	private const int WM_LBUTTONDOWN = 0x0201;
	private static IntPtr hookID = IntPtr.Zero;
	private static LowLevelMouseProc proc = HookCallback;

	private static Callable _gdscriptCallback;

	public delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);

	[DllImport("user32.dll", SetLastError = true)]
	private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);

	[DllImport("user32.dll", SetLastError = true)]
	[return: MarshalAs(UnmanagedType.Bool)]
	private static extern bool UnhookWindowsHookEx(IntPtr hhk);

	[DllImport("user32.dll")]
	private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

	[DllImport("kernel32.dll")]
	private static extern IntPtr GetModuleHandle(string lpModuleName);

	public static void SetHook(Callable callback)
	{
		using (Process curProcess = Process.GetCurrentProcess())
		using (ProcessModule curModule = curProcess.MainModule)
		{
			hookID = SetWindowsHookEx(WH_MOUSE_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
			_gdscriptCallback = callback;
		}
	}

	public static void Unhook()
	{
		UnhookWindowsHookEx(hookID);
	}

	private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
	{
		if (nCode >= 0)
		{
			int msg = wParam.ToInt32();
			if ( msg == WM_LBUTTONDOWN)
			{
				_gdscriptCallback.Call();
			}         
		}

		return CallNextHookEx(hookID, nCode, wParam, lParam);
	}
}
