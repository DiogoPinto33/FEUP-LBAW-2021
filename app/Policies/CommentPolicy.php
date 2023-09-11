<?php

namespace App\Policies;

use App\Models\Comment;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class CommentPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can update the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Comment  $comment
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function update(User $user, Comment $comment)
    {
        return ($user->id == $comment->writer || $user->is_admin);
    }

    /**
     * Determine whether the user can delete the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Comment  $comment
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function delete(User $user, Comment $comment)
    {
        return ($user->id == $comment->writer || $user->is_admin);
    }
	
	public function vote(User $user, Comment $comment)
    {
        return (!$user->voteOnComment->contains($comment->id_comment) and $user->id != $comment->writer);
    }
	
	public function deleteVote(User $user, Comment $comment)
    {
        return $user->voteOnComment->contains($comment->id_comment);
    }
}
