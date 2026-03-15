<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ConversationManagerController extends Controller
{
    public function rename(Request $request, $id)
    {
        $request->validate([
            'title' => 'required|string|max:255'
        ]);

        // Update the table name if yours isn't exactly 'chats'
        DB::table('chats')->where('id', $id)->update(['title' => $request->title]);

        return response()->json(['success' => true, 'message' => 'Chat renamed successfully']);
    }

    public function destroy($id)
    {
        // Update the table name if yours isn't exactly 'chats'
        DB::table('chats')->where('id', $id)->delete();
        
        // Optional: you can also delete related messages here
        // DB::table('messages')->where('chat_id', $id)->delete();

        return response()->json(['success' => true, 'message' => 'Chat deleted successfully']);
    }
}